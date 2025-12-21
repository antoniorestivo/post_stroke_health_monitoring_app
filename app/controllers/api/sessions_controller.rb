class Api::SessionsController < Api::BaseController
  skip_before_action :authenticate_user
  def create
    user = User.find_by(email: params[:email].to_s.downcase.strip)

    UserLogin.create(user: user) if user

    if user && !user.email_confirmed?
      ensure_confirmation_token(user)
      send_confirmation_email(user)

      render json: {
        error: 'Email not confirmed',
        message: 'We have sent you an email with a confirmation link. Please confirm your email before logging in.'
      }, status: :unauthorized and return
    end

    if user&.authenticate(params[:password].to_s)
      jwt = JWT.encode(
        {
          user_id: user.id,
          exp: 24.hours.from_now.to_i
        },
        jwt_secret_key,
        'HS256'
      )
      render json: {
        jwt: jwt,
        user: {
          id: user.id,
          email: user.email
        }
      }, status: :created
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  private

  def ensure_confirmation_token(user)
    return if user.confirmation_token.present?

    if user.respond_to?(:generate_confirmation_token)
      user.generate_confirmation_token
      user.save!
    else
      user.update!(confirmation_token: SecureRandom.hex(20))
    end
  rescue StandardError => e
    Rails.logger.error("Failed to ensure confirmation token: #{e.class} - #{e.message}")
  end

  def send_confirmation_email(user)
    if user.respond_to?(:send_confirmation_email)
      user.send_confirmation_email
    elsif defined?(UserMailer)
      UserMailer.confirmation_email(user).deliver_later
    end
  rescue StandardError => e
    Rails.logger.error("Failed to send confirmation email: #{e.class} - #{e.message}")
  end

  def jwt_secret_key
    ENV['JWT_SECRET_KEY'].presence || Rails.application.secret_key_base
  end
end