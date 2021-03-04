class Api::UsersController < ApplicationController
 def create
  @user = User.new(
    email: params[:email],
    password_digest: params[:password_digest]
  )
 if @user.save
  render "show.json.jb"
  else
   render json: {errors: @actor.errors.full_messages}, status: :unprocessable_entity
  
 end
    
    
  
 end
 def show
  @user = User.find_by(id: params[:id])
  render "show.json.jb"
 end

end


