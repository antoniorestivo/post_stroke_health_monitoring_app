module Api
  class UserChartsController < ApplicationController
    before_action :authenticate_user
    def index
      @charts = current_user.user_charts
    end

    def show
      @chart = UserChart.find(params[:id])
      y_variable = @chart.y_label
      journals = current_user.journals.order(created_at: :asc)
      x_data = journals.map { |j| j.created_at.strftime('%m-%d-%Y') }
      y_data = journals.map { |j| j.metrics[y_variable] }
      @data = { x: x_data, y: y_data }
    end

    def new
      @health_metrics = current_user.health_metrics.select(:metric_name)
      render json: @health_metrics
    end

    def create
      UserChart.create_with_implicit_type(permitted_params)
    end

    def update
    end

    def destroy
    end

    private

    def permitted_params
      params.permit(:x_label, :y_label, :user_id, :title)
    end
  end
end
