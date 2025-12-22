module AuthHelpers
  def auth_headers_for(user)
    token = JWT.encode(
      { user_id: user.id, exp: 24.hours.from_now.to_i, email: user.email },
      Rails.application.secret_key_base,
      "HS256"
    )

    {
      "HTTP_AUTHORIZATION" => "Bearer #{token}",
      "ACCEPT" => "application/json",
      "CONTENT_TYPE" => "application/json"
    }
  end
end
