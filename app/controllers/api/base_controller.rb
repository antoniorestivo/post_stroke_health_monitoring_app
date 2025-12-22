module Api
  class BaseController < ActionController::API
    before_action :authenticate_user

    private

    def current_user
      auth_header =
        request.headers["Authorization"] ||
        request.headers["HTTP_AUTHORIZATION"]

      return unless auth_header&.match?(/\ABearer /)

      token = auth_header.split(" ", 2).last

      decoded_token = JWT.decode(
        token,
        Rails.application.secret_key_base,
        true,
        algorithm: "HS256"
      )

      User.find_by(id: decoded_token[0]["user_id"])
    rescue JWT::ExpiredSignature, JWT::DecodeError
      nil
    end

    def authenticate_user
      Rails.logger.warn("Headers: #{request.headers.to_h.slice('Authorization', 'HTTP_AUTHORIZATION')}")

      render json: { error: "Unauthorized" }, status: :unauthorized unless current_user
    end
  end
end
