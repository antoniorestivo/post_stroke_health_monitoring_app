class Api::SessionsController < Api::BaseController
  skip_before_action :authenticate_user
  def create
    Rails.logger.warn('LOGGING IN!!!!!!!!!!!')
    user = User.find_by(email: params[:email])

    # Only track login attempts when a user record exists
    UserLogin.create(user: user) if user

    # If the user exists but has not confirmed their email, (re)send confirmation
    if user && !user.email_confirmed?
      # Ensure the user has a confirmation token
      if user.confirmation_token.blank?
        # Prefer a dedicated method if it exists, otherwise generate directly
        if user.respond_to?(:generate_confirmation_token)
          user.generate_confirmation_token
          user.save!
        else
          user.update!(
            confirmation_token: SecureRandom.hex(20)
          )
        end
      end

      # Attempt to send the confirmation email if the model exposes such a method
      if user.respond_to?(:send_confirmation_email)
        user.send_confirmation_email
      else
        # Fallback: call mailer directly if it's available
        if defined?(UserMailer)
          begin
            UserMailer.confirmation_email(user).deliver_later
          rescue => e
            Rails.logger.error("Failed to send confirmation email: #{e.class} - #{e.message}")
          end
        end
      end

      render json: {
        error: 'Email not confirmed',
        message: 'We have sent you an email with a confirmation link. Please confirm your email before logging in.'
      }, status: :unauthorized and return
    end

    Rails.logger.warn(user.email) if user
    if user && user.authenticate(params[:password])
      jwt = JWT.encode(
        {
          user_id: user.id,
          exp: 24.hours.from_now.to_i
        },
        Rails.application.secret_key_base,
        "HS256"
      )
      render json: { jwt: jwt, email: user.email, user_id: user.id }, status: :created
    else
      render json: {}, status: :unauthorized
    end
  end
end