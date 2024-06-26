module Api
  class UserChartsController < ApplicationController
    before_action :authenticate_user
    def index
      @charts = current_user.user_charts
    end

    def show
      @chart = UserChart.find(params[:id])
      journals = current_user.journals.order(created_at: :asc)
      @data = ::UserCharts::Enrich.new(@chart, journals).data
    end

    def new
      @health_metrics = current_user.health_metrics.select(:metric_name)
      render json: @health_metrics
    end

    def create
      UserChart.create_with_implicit_type(permitted_params)
    end

    def edit
      chart = UserChart.find(params[:id])
      health_metrics = current_user.health_metrics.select(:metric_name)
      @data = { chart: chart, health_metrics: health_metrics }
      render json: @data
    end

    def update
      UserChart.find(params[:id]).update(permitted_params)
    end

    def destroy
      UserChart.find(params[:id]).destroy
    end

    private

    def permitted_params
      params.permit(:x_label, :y_label, :user_id, :title)
    end
  end
end
