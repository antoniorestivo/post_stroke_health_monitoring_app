class Api::ConditionsController < Api::BaseController
  before_action :set_condition, only: [:show, :update, :destroy]

  def index
    @conditions = current_user.conditions
    render "index"
  end

  def show
    render "show"
  end

  def create
    @condition = current_user.conditions.new(condition_params)
    if @condition.save
      render "show"
    else
      render json: { errors: @condition.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @condition.update(condition_params)
      render "show"
    else
      render json: { errors: @condition.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @condition.destroy
    render json: { message: "Condition successfully destroyed!" }
  end

  private

  def set_condition
    @condition = current_user.conditions.find_by(id: params[:id])
    return if @condition

    render json: { errors: "Not found" }, status: :not_found
  end

  def condition_params
    params.require(:condition).permit(:name, :support, :description, :image_url, :video_url)
  end
end