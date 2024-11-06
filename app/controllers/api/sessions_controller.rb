class Api::SessionsController < ApplicationController
  def create
    Rails.logger.warn('LOGGING IN!!!!!!!!!!!')
    user = User.find_by(email: params[:email])

    UserLogin.create(user: user)

    Rails.logger.warn(user.email)
    if user && user.authenticate(params[:password])
      jwt = JWT.encode(
        {
          user_id: user.id, # the data to encode
          exp: 24.hours.from_now.to_i # the expiration time
        },
        Rails.application.secret_key_base, # the secret key
        "HS256" # the encryption algorithm
      )
      render json: { jwt: jwt, email: user.email, user_id: user.id }, status: :created
    else
      render json: {}, status: :unauthorized
    end
  end
end

