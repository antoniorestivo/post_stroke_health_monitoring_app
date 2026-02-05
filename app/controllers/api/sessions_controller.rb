class Api::SessionsController < Api::BaseController
  skip_before_action :authenticate_user
  def create
    user = User.find_by(email: params[:email].to_s.downcase.strip)

    if user && !user.email_confirmed?
      ensure_confirmation_token(user)
      send_confirmation_email(user)

      render json: { errors: ['Invalid email or password'] },
             status: :unauthorized and return
    end

    if user&.authenticate(params[:password].to_s)
      UserLogin.create!(user: user)

      jwt = JWT.encode(
        {
          user_id: user.id,
          exp: 24.hours.from_now.to_i,
          email: user.email
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
      render json: { errors: ['Invalid email or password'] }, status: :unauthorized
    end
  end

  def demo
    demo_user = nil

    User.transaction do
      demo_user = User.create!(
        email: "demo_#{SecureRandom.hex(6)}@example.com",
        email_confirmed: true,
        first_name: 'Alex',
        last_name: 'The Demo User',
        password: SecureRandom.hex(12),
        demo: true,
        confirmed_at: Time.current
      )
      DemoSeedUser.call(demo_user)
    end

    token = JWT.encode(
      {
        user_id: demo_user.id,
        exp: 24.hours.from_now.to_i,
        email: demo_user.email
      },
      jwt_secret_key,
      'HS256'
    )

    render json: {
      jwt: token,
      user: {
        id: demo_user.id,
        email: demo_user.email
      }
    }, status: :created
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
