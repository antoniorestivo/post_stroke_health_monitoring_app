Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins do |source, _env|
      allowed_origins = []

      if Rails.env.development? || Rails.env.test?
        allowed_origins << 'http://localhost:5173'
        allowed_origins << 'http://127.0.0.1:5173'
      end

      frontend_origin = ENV['FRONTEND_APP_ORIGIN']
      allowed_origins << frontend_origin if frontend_origin.present?

      allowed_origins.include?(source)
    end

    resource "*",
             headers: :any,
             methods: %i[get post put patch delete options head],
             credentials: false,
             max_age: 600
  end
end