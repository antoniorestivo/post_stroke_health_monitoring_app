class Api::UsersController < ApplicationController
 def create
    @user = User.new(
    email: params[:email],
    password_digest: params[:password_digest]
  )
  if @user.save
    render "show.json.jb"
  else
    render json: { errors: @user.errors.full_messages }, status: :bad_request
  end
 end


def show
  @user = User.find_by(id: params[:id])
  render "show.json.jb"
 end
 
 def update
  #update users
  user_id = params[:id]
  @user = User.find_by(id: user_id)
  @user.email = params[:email] || @user.email
  @user.password_digest = params[:password_digest] || @user.password_digest

  if @user.save
    render json: { message: "User updated successfully" }, status: :created
  else  
    render json: {errors: @user.errors.full_messages}, status: 422
  end
end

def destroy
  user = User.find_by(id: params[:id])
  user.destroy
  render json: {message: "User successfully deleted!"}
end

end








