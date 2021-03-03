class Api::UsersController < ApplicationController
 def create
  @user = User.new(
    email: params[:email],
    password_digest: params[:password_digest]
  )
  @user.save
  render "show.json.jb"
 end
end
