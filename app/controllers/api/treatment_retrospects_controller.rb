module Api
  class TreatmentRetrospectsController < Api::BaseController
    before_action :load_treatment
    def index
      limit = params[:limit] || 9
      offset = params[:offset] || 0
      @treatment_retrospects = TreatmentRetrospect.where(treatment: @treatment)
                                                  .limit(limit)
                                                  .offset(offset)
      @total_records = TreatmentRetrospect.where(treatment: @treatment).count
    end

    def show
      @treatment_retrospect = TreatmentRetrospect.where(id: params[:id], treatment: @treatment).first
    end

    def create
      TreatmentRetrospect.create!(
        treatment: @treatment,
        rating: permitted_params[:rating],
        feedback: permitted_params[:feedback]
      )
      render json: { success: true }, status: :ok
    end

    def update
      treatment_retrospect = TreatmentRetrospect.where(id: params[:id], treatment: @treatment).first
      if treatment_retrospect &&
        treatment_retrospect.update(rating: permitted_params[:rating], feedback: permitted_params[:feedback])

        render json: { success: true }, status: :ok
      else
        render json: { success: false }, status: :unprocessable_content
      end

    end

    def destroy
      treatment_retrospect = TreatmentRetrospect.where(id: params[:id], treatment: @treatment).first
      if treatment_retrospect
        treatment_retrospect.destroy
        render json: { success: true }, status: :ok
      else
        render json: { success: false }, status: :unprocessable_content
      end
    end

    private

    def permitted_params
      params.permit(:feedback, :treatment_id, :rating)
    end

    def load_treatment
      @treatment = current_user.treatments.where(id: params[:treatment_id]).first
      return if @treatment

      render json: { errors: "Not found" }, status: :not_found
    end
  end
end
