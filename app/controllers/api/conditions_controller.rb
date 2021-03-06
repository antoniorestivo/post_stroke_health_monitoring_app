class Api::ConditionsController < ApplicationController
 def index
  @conditions = Condition.all
  render "index.json.jb"
 end
 def show
  condition_id = params[:id]
  @condition = Condition.find_by(id: condition_id)
  render "show.json.jb"
 end
 def create
  @condition = Condition.new(
    user_id: params[:user_id],
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
  @condition = Condition.find_by(id: condition_id)
 
  @condition.name = params[:name] || @condition.name
  @condition.support = params[:support] || @condition.support
  @condition.treatment_retrospect = params[:treatment_retrospect] || @condition.treatment_retrospect
  @condition.treatment_plan = params[:treatment_plan] || @condition.treatment_plan
  @condition.image_url = params[:image_url] || @condition.image_url
  @condition.video_url = params[:video_url] || @condition.video_url
  if @condition.save
    render "show.json.jb"
  else
    render json: {errors: @condition.error.full_messages}, status: 422
  end
 end
 
 def destroy
   condition = Condition.find_by(id: params[:id])
   condition.destroy
   render json: {message: "Condition successfully destroyed!"}
 end


end
