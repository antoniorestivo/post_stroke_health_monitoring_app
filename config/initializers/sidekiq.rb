# frozen_string_literal: true

unless Rails.env.test?
  require "sidekiq"

  Sidekiq.configure_server do |config|
    config.redis = {
      url: ENV.fetch("REDIS_URL", "redis://redis:6379/0"),
      size: Integer(ENV.fetch("SIDEKIQ_SERVER_REDIS_SIZE", 27))
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: ENV.fetch("REDIS_URL", "redis://redis:6379/0"),
      size: Integer(ENV.fetch("SIDEKIQ_CLIENT_REDIS_SIZE", 5))
    }
  end
end
