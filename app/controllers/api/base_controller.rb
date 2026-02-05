module Api
  class BaseController < ActionController::API
    before_action :authenticate_user

    private

    def current_user
      return @current_user if defined?(@current_user)

      token = bearer_token
      return @current_user = nil if token.blank?

      payload, = JWT.decode(
        token,
        jwt_secret_key,
        true,
        algorithm: "HS256"
      )

      @current_user = User.find_by(id: payload["user_id"])
    rescue JWT::ExpiredSignature, JWT::DecodeError
      @current_user = nil
    end

    def authenticate_user
      render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
    end

    def bearer_token
      auth_header = request.headers["Authorization"] || request.headers["HTTP_AUTHORIZATION"]
      return nil unless auth_header&.start_with?("Bearer ")

      auth_header.split(" ", 2).last
    end

    def jwt_secret_key
      ENV["JWT_SECRET_KEY"].presence || Rails.application.secret_key_base
    end
  end
end
