module Api
  class TreatmentRetrospectsController < ApplicationController
    before_action :authenticate_user

    def index
      @treatment_retrospects = TreatmentRetrospect.where(treatment_id: params[:treatment_id])
    end

    def show
      @treatment_retrospect = TreatmentRetrospect.find(params[:id])
    end

    def create
      TreatmentRetrospect.create(treatment_id: params[:treatment_id], rating: permitted_params[:rating], feedback: permitted_params[:feedback])
    end

    def update
      treatment_retrospect = TreatmentRetrospect.find(params[:id])
      treatment_retrospect.update(rating: permitted_params[:rating], feedback: permitted_params[:feedback])
    end

    def destroy
      TreatmentRetrospect.find(params[:id]).destroy
    end

    private

    def permitted_params
      params.permit(:feedback, :treatment_id, :rating)
    end
  end
end
