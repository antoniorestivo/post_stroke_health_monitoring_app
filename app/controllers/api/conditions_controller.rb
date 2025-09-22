class Api::ConditionsController < ApplicationController
  before_action :authenticate_user

  def index
    @conditions = current_user.conditions
    render "index"
  end
  def show
    condition_id = params[:id]
    @condition = current_user.conditions.find_by(id: condition_id)
    if @condition
      render "show"
    else
      render json: {errors: "Unauthorized"}, status: 422
    end
  end
  def create
    @condition = Condition.new(
    user_id: current_user.id,
    name: params[:name],
    support: params[:support],
    description: params[:description],
    image_url: params[:image_url],
    video_url: params[:video_url]
  )
    if @condition.save
      render "show"
    else
      render json: {errors: @condition.errors.full_messages}, status: 422
    end
  end
  def update
    condition_id = params[:id]
    @condition = current_user.conditions.find_by(id: condition_id)
    if @condition
      @condition.name = params[:name].presence || @condition.name
      @condition.support = params[:support].presence || @condition.support
      @condition.image_url = params[:image_url].presence || @condition.image_url
      @condition.video_url = params[:video_url].presence || @condition.video_url
      @condition.description = params[:description].presence || @condition.description

      if @condition.save
        render "show"
      else
        render json: {errors: @condition.error.full_messages}, status: 422
      end
    else
      render json: {errors: "Unauthorized"}, status: 422
    end
  end

  def destroy
    condition = current_user.conditions.find_by(id: params[:id])
    if condition
      condition.destroy
      render json: {message: "Condition successfully destroyed!"}
    else
      render json: {message: "Condition does not exist"}, status: 422
    end
  end
end
