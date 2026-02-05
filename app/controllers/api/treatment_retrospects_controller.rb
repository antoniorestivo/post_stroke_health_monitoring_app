module Api
  class TreatmentRetrospectsController < Api::BaseController
    before_action :set_treatment
    before_action :set_treatment_retrospect, only: [:show, :update, :destroy]

    def index
      limit = (params[:limit] || 9).to_i
      limit = 100 if limit > 100
      limit = 9 if limit <= 0

      offset = (params[:offset] || 0).to_i
      offset = 0 if offset.negative?

      scope = @treatment.treatment_retrospects

      @treatment_retrospects = scope.limit(limit).offset(offset)
      @total_records = scope.count
    end

    def show
    end

    def create
      @treatment.treatment_retrospects.create!(retrospect_params)
      head :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
    end

    def update
      @treatment_retrospect.update!(retrospect_params)
      head :no_content
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
    end

    def destroy
      @treatment_retrospect.destroy
      head :no_content
    end

    private

    def set_treatment
      @treatment = current_user.treatments.find(params[:treatment_id])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: ["Not found"] }, status: :not_found
      return
    end

    def set_treatment_retrospect
      @treatment_retrospect =
        @treatment.treatment_retrospects.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: ["Not found"] }, status: :not_found
      return
    end

    def retrospect_params
      params.require(:treatment_retrospect).permit(:rating, :feedback)
    end
  end
end
