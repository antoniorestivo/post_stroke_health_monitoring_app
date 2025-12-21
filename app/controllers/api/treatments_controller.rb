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
      @treatment = @condition.treatments.build(treatment_params)

      if @treatment.save
        render :show, status: :created
      else
        render json: { errors: @treatment.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def update
      if @treatment.update(treatment_params)
        render :show
      else
        render json: { errors: @treatment.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def destroy
      @treatment.destroy
      head :no_content
    end

    private

    def set_condition
      @condition = current_user.conditions.find_by(id: params[:condition_id])
      render json: { errors: "Not Found" }, status: :not_found unless @condition
    end

    def set_treatment
      @treatment = @condition.treatments.find_by(id: params[:id])
      render json: { errors: "Not Found" }, status: :not_found unless @treatment
    end

    def treatment_params
      params.require(:treatment).permit(:description)
    end
  end
end