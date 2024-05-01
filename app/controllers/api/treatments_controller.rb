module Api
  class TreatmentsController < ApplicationController
    def index
      @treatments = Treatment.where(condition_id: params[:condition_id])
    end

    def new
    end

    def show
    end

    def create
    end

    def edit
    end

    def update
    end

    def destroy
    end
  end
end
