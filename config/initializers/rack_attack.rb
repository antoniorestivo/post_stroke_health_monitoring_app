# frozen_string_literal: true

class Rack::Attack
  # Use a time-based sliding window for throttles
  Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new(
    url: ENV.fetch('REDIS_URL'),
    namespace: 'rack-attack'
  )

  # Allow all local traffic (useful for health checks, internal tooling, etc.)
  safelist('allow-localhost') do |req|
    # 127.0.0.1, ::1, and docker-style internal hostnames can be allowed here if needed
    req.ip == '127.0.0.1' || req.ip == '::1'
  end

  # Throttle excessive POSTs to the login endpoint to mitigate brute-force attacks.
  #
  # Keyed by IP, with a low burst limit and short window. Adjust limits based on
  # real production traffic patterns.
  throttle('logins/ip', limit: 10, period: 60.seconds) do |req|
    if req.post? && req.path =~ %r{\A/api/sessions\z}
      req.ip
    end
  end

  # Optional: secondary throttle keyed by account identifier to slow attacks
  # distributed across many IPs. We assume JSON payloads for the API and a
  # conventional "email" login field.
  throttle('logins/account', limit: 20, period: 60.seconds) do |req|
    if req.post? && req.path =~ %r{\A/api/sessions\z} && req.media_type == 'application/json'
      begin
        body = JSON.parse(req.body.read)
        req.body.rewind
        body['email'].to_s.downcase.presence
      rescue JSON::ParserError
        req.body.rewind
        nil
      end
    end
  end

  # Generic protection against basic abusive clients: cap overall request rate
  # per IP to reduce scraping and simple DoS attempts.
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # throttle sensitive demo endpoint that creates demo users and associated records
  throttle('demo-login/ip', limit: 5, period: 1.hour) do |req|
    if req.post? && req.path == '/api/demo_login'
      req.ip
    end
  end


  # Blocklist hook (for future use). You can add known-bad IPs or patterns here.
  # Example:
  # blocklist('block-bad-ips') do |req|
  #   bad_ips = ENV.fetch('RACK_ATTACK_BLOCKLIST_IPS', '').split(',')
  #   bad_ips.include?(req.ip)
  # end

  # Configure responses for throttled and blocked requests with safe, generic
  # error messages that do not leak sensitive details.
  self.throttled_responder = lambda do |env|
    now = Time.now.utc
    retry_after = (env['rack.attack.match_data'] || {})[:period]
    headers = {
      'Content-Type' => 'application/json',
      'Retry-After' => retry_after.to_s
    }

    [
      429,
      headers,
      [
        {
          error: 'Too many requests',
          message: 'Please slow down and try again later.',
          timestamp: now.iso8601
        }.to_json
      ]
    ]
  end

  self.blocklisted_responder = lambda do |_env|
    [
      403,
      { 'Content-Type' => 'application/json' },
      [
        {
          error: 'Forbidden',
          message: 'Your access to this service has been restricted.'
        }.to_json
      ]
    ]
  end
end