module Api
  class UsersController < ::Api::BaseController
    skip_before_action :authenticate_user, only: %i(create confirm_email)
    def create
      @user = User.new(**permitted_params.compact_blank)
      if @user.save
        render "show", formats: [:json]
      else
        render json: { errors: @user.errors.full_messages }, status: :bad_request
      end
    end

    def show
      @user = current_user
      @monthly_statistics = current_user.usage_statistics.to_h
                                        .with_indifferent_access
                                        .fetch(:months, {})
                                        .each_with_object({}) do |(k, v), memo|
        memo[:labels] ||= []
        memo[:labels].push(k.to_s.capitalize)
        memo[:logins] ||= []
        memo[:logins].push(v)
      end
      begin_date_dimension_id = Time.now.utc.to_date.advance(days: -6).strftime('%Y%m%d').to_i
      logins = UserLogin.where("date_dimension_id > ?", begin_date_dimension_id).group(:date_dimension_id).count
      dates = (0..6).map { |i| (Time.now.utc.to_date - i).strftime('%Y%m%d') }.reverse
      @daily_statistics = dates.each_with_object({}) do |date_dimension_id, memo|
        memo[:labels] ||= []
        memo[:labels].push(date_dimension_id)
        memo[:logins] ||= []
        memo[:logins].push(logins.fetch(date_dimension_id.to_i, 0))
      end
      @profile_image_url = url_for(@user.profile_image) if @user.profile_image&.attached?
      render "show", formats: [:json]
    end

    def update
      # fields = permitted_params.to_h.compact
      @user = current_user
      @user.profile_image.attach(permitted_params[:profile_image])
      new_attributes = permitted_params.slice(:first_name, :last_name, :email, :password).compact_blank
      @user.assign_attributes(**new_attributes)
      if @user.save!
        render "show", status: 200, formats: [:json]
      else
        render json: {errors: @user.errors.full_messages}, status: 422
      end
    end

    def confirm_email
      @user = User.find_by(confirmation_token: params[:token])
      if @user
        @user.confirm_email!(params[:token])
        render json: { success: 'true' }
      else
        render json: { success: 'false', errors: 'User not found' }
      end
    end

    def permitted_params
      params.permit(:first_name, :last_name, :email, :password, :old_password, :password_confirmation, :profile_image)
    end

    def destroy
      user = current_user
      user.destroy
      render json: {message: "User successfully deleted!"}
    end
  end
end
