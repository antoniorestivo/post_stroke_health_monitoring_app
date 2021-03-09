class Api::UsersController < ApplicationController
  
  before_action :authenticate_user, except: [:create]
  def create
    @user = User.new(
      email: params[:email],
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )
    if @user.save
      render "show.json.jb"
    else
      render json: { errors: @user.errors.full_messages }, status: :bad_request
    end
  end

  def show
    @user = current_user
    render "show.json.jb"
  end
 
  def update
    #update users
  
    @user = current_user
    @user.email = params[:email] || @user.email
    if params[:password]
      if @user.authenticate(params[:old_password])
        @user.update!(
          password: params[:password],
          password_confirmation: params[:password_confirmation]
        ) 
      end
    end
    if @user.save
      render "show.json.jb", status: 200
    else  
      render json: {errors: @user.errors.full_messages}, status: 422
    end
  end

  def destroy
    user = current_user
    user.destroy
    render json: {message: "User successfully deleted!"}
  end

end








