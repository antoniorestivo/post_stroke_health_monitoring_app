module Api
  class TreatmentsController < ApplicationController
    before_action :authenticate_user
    before_action :validate_user_condition, except: :all
    def index
      @treatments = Treatment.where(condition_id: params[:condition_id])
    end

    def all
      @relation = current_user.conditions.includes(:treatments)
    end

    def show
      @treatment = Treatment.find(params[:id])
    end

    def create
      Treatment.create(condition_id: permitted_params[:condition_id], description: permitted_params[:description])
    end

    def update
      treatment = Treatment.find(params[:id])
      treatment.update(permitted_params)
    end

    def destroy
      Treatment.find(params[:id]).destroy
    end

    private

    def permitted_params
      params.permit(:description, :condition_id, :treatment)
    end

    def validate_user_condition
      condition_user_id = Condition.find(params[:condition_id]).user_id
      render json: { errors: "Unauthorized" }, status: 422 unless current_user.id == condition_user_id
    end
  end
end
