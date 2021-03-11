class Api::ConditionsController < ApplicationController
  before_action :authenticate_user
  
  def index
    @conditions = current_user.conditions
    render "index.json.jb"
  end
  def show
    condition_id = params[:id]
    @condition = current_user.conditions.find_by(id: condition_id)
    if @condition
      render "show.json.jb"
    else
      render json: {errors: "Unauthorized"}, status: 422
    end
  end
  def create
    @condition = Condition.new(
    user_id: current_user.id,
    name: params[:name],
    support: params[:support],
    treatment_retrospect: params[:treatment_retrospect],
    treatment_plan: params[:treatment_plan],
    image_url: params[:image_url],
    video_url: params[:video_url]
  )
    if @condition.save
      render "show.json.jb"
    else
      render json: {errors: @condition.errors.full_messages}, status: 422
    end
  end
  def update
    condition_id = params[:id]
    @condition = current_user.conditions.find_by(id: condition_id)
    if @condition
      @condition.name = params[:name] || @condition.name
      @condition.support = params[:support] || @condition.support
      @condition.treatment_retrospect = params[:treatment_retrospect] || @condition.treatment_retrospect
      @condition.treatment_plan = params[:treatment_plan] ||@condition.treatment_plan
      @condition.image_url = params[:image_url] || @condition.image_url
      @condition.video_url = params[:video_url] || @condition.video_url
    
      if @condition.save
        render "show.json.jb"
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
