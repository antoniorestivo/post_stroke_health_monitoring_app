module Api
  class TreatmentsController < Api::BaseController
    before_action :set_condition, except: :all
    before_action :set_treatment, only: [:show, :update, :destroy]

    def index
      @treatments = @condition.treatments
    end

    def all
      @relation = current_user.conditions.includes(:treatments)
    end

    def show
    end

    def create
      @treatment = @condition.treatments.create!(treatment_params)
      render :show, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
    end

    def update
      @treatment.update!(treatment_params)
      render :show
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
    end

    def destroy
      @treatment.destroy
      head :no_content
    end

    private

    def set_condition
      @condition = current_user.conditions.find(params[:condition_id])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: ["Not found"] }, status: :not_found
      return
    end

    def set_treatment
      @treatment = @condition.treatments.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: ["Not found"] }, status: :not_found
      return
    end

    def treatment_params
      params.require(:treatment).permit(:description, :name)
    end
  end
end
