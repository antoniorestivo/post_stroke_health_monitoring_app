module Api
  class UsersController < ::Api::BaseController
    skip_before_action :authenticate_user, only: %i[create confirm_email]

    def create
      @user = User.new(**create_params.compact_blank)

      if @user.save
        render "show", formats: [:json]
      else
        render json: { errors: @user.errors.full_messages },
               status: :unprocessable_content
      end
    end

    def show
      @user = current_user

      @monthly_statistics =
        current_user.usage_statistics.to_h
                    .with_indifferent_access
                    .fetch(:months, {})
                    .each_with_object({ labels: [], logins: [] }) do |(k, v), memo|
          memo[:labels] << k.to_s.capitalize
          memo[:logins] << v
        end

      begin_date_dimension_id =
        Time.now.utc.to_date.advance(days: -6).strftime('%Y%m%d').to_i

      logins =
        UserLogin.where("date_dimension_id > ?", begin_date_dimension_id)
                 .group(:date_dimension_id)
                 .count

      dates =
        (0..6).map { |i| (Time.now.utc.to_date - i).strftime('%Y%m%d') }.reverse

      @daily_statistics =
        dates.each_with_object({ labels: [], logins: [] }) do |date, memo|
          memo[:labels] << date
          memo[:logins] << logins.fetch(date.to_i, 0)
        end

      @profile_image_url = url_for(@user.profile_image) if @user.profile_image&.attached?

      render "show", formats: [:json]
    end

    def confirm_email
      user = User.find_by(confirmation_token: params[:token])

      if user
        user.confirm_email!(params[:token])
      end

      render json: { success: true }
    end

    def destroy
      current_user.destroy
      render json: { message: "User successfully deleted!" }
    end

    private

    def create_params
      params.require(:user).permit(
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation,
        :profile_image
      )
    end
  end
end
