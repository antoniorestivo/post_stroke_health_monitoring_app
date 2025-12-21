# frozen_string_literal: true

# Configure and validate the application's secret tokens and JWT configuration.
Rails.application.config.to_prepare do
  # Legacy Rails session/secret token support (for older Rails < 5 apps that still read this file)
  if Rails.application.respond_to?(:secrets) && Rails.application.secrets.secret_key_base.blank?
    secret_key_base = ENV['SECRET_KEY_BASE']

    if secret_key_base.blank?
      raise 'SECRET_KEY_BASE environment variable must be set in production for session integrity'
    end

    Rails.application.secrets.secret_key_base = secret_key_base
    if Rails.application.config.respond_to?(:secret_key_base=)
      Rails.application.config.secret_key_base = secret_key_base
    end
  end

  # JWT secret configuration
  jwt_secret = ENV['JWT_SECRET_KEY'] || ENV['JWT_SECRET'] || ENV['DEVISE_JWT_SECRET_KEY']

  if Rails.env.production?
    if jwt_secret.blank?
      raise 'JWT_SECRET_KEY environment variable must be set in production for JWT signing'
    end
  else
    # Provide a deterministic but clearly non-production default in non-production environments
    jwt_secret ||= 'development-test-jwt-secret-key-change-me'
  end

  # Make JWT configuration available to the application
  Rails.application.config.x.jwt = ActiveSupport::OrderedOptions.new
  Rails.application.config.x.jwt.secret = jwt_secret
  Rails.application.config.x.jwt.algorithm = 'HS256'
  Rails.application.config.x.jwt.issuer = ENV['JWT_ISSUER'].presence || "api-#{Rails.env}"
  Rails.application.config.x.jwt.audience = ENV['JWT_AUDIENCE'].presence || "api-client-#{Rails.env}"
  Rails.application.config.x.jwt.expiration_seconds =
    (ENV['JWT_EXPIRATION_SECONDS'] || ENV['JWT_EXPIRATION'] || 60.minutes.to_i).to_i
end