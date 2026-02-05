module Api
  class UserChartsController < Api::BaseController
    before_action :set_chart, only: [:show, :edit, :update, :destroy]

    def index
      @charts = current_user.user_charts
      render :index, formats: [:json]
    end

    def show
      journals = current_user.journals.order(created_at: :asc)
      @data = ::UserCharts::Enrich.build(@chart, journals)

      render :show, formats: [:json]
    end

    def new
      @health_metrics = current_user.health_metrics
      @treatments = current_user.treatments
      render json: { metrics: @health_metrics, treatments: @treatments }
    end

    def create
      chart = UserChart.create_with_mode!(current_user, chart_params)
      render json: { id: chart.id }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
    end

    def edit
      health_metrics = current_user.health_metrics.select(:metric_name)
      render json: { chart: @chart, health_metrics: health_metrics }
    end

    def update
      @chart.update!(chart_params)
      head :no_content
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
    end

    def destroy
      @chart.destroy
      head :no_content
    end

    private

    def set_chart
      @chart = current_user.user_charts.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      render json: { errors: ["Not found"] }, status: :not_found
      return
    end

    def chart_params
      params.require(:user_chart).permit(
        :x_label,
        :y_label,
        :title,
        :chart_mode,
        options: {}
      )
    end
  end
end
