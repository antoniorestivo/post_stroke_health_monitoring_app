module Api
  class JournalTemplatesController < Api::BaseController
    before_action :set_journal_template, only: [:edit, :update]
    before_action :authorize_journal_template, only: [:edit, :update]

    def new
    end

    def create
      journal_template = JournalTemplate.new(user: current_user)
      field_names(create_params).each do |field_name, v|
        id = field_name.scan(/\d+/).first
        field_unit = create_params["field_unit_#{id}"]
        field_data_type = create_params["field_data_type_#{id}"]
        warning_threshold = create_params["warning_threshold_#{id}"]
        HealthMetric.create(journal_template: journal_template, metric_name: v, metric_data_type: field_data_type,
                            metric_unit_name: field_unit, warning_threshold: warning_threshold)
      end

      if journal_template.save
        render json: { id: journal_template.id }, status: :created
      else
        render json: { errors: journal_template.errors.full_messages }, status: :unprocessable_content
      end
    end

    def edit
      render "edit"
    end

    def update
      if update_params["metrics"].blank?
        return render json: { errors: ["Metrics are required"] }, status: :unprocessable_content
      end

      @template.health_metrics.destroy_all

      update_params["metrics"].each do |metric|
        values = metric.slice("metric_name", "metric_data_type", "metric_unit_name", "warning_threshold")
        @template.health_metrics.create(values)
      end

      if @template.errors.empty?
        head :no_content
      else
        render json: { errors: @template.errors.full_messages }, status: :unprocessable_content
      end
    end

    private

    def set_journal_template
      @template = current_user.journal_template
      return if @template

      render json: { errors: ["Journal template not found"] }, status: :not_found
    end

    def authorize_journal_template
      return if @template.user_id == current_user.id

      render json: { errors: ["Unauthorized"] }, status: :forbidden
    end

    def update_params
      @update_params ||= params.require(:template).permit(
        *fields,
        metrics: [
          "metric_name",
          "metric_data_type",
          "metric_unit_name",
          "warning_threshold"
        ]
      )
    end

    def create_params
      @create_params ||= params.require(:template).permit(*fields)
    end

    def field_names(params)
      params.select { |k, v| k.match?(/field_name_\d+/) && v.present? }
    end

    def fields
      return [] unless params[:template].is_a?(ActionController::Parameters) || params[:template].is_a?(Hash)

      regex_pattern = /(field_(name|unit|data_type)_\d+)|(warning_threshold_\d+)/
      params[:template].keys.select { |k| k.match?(regex_pattern) }
    end

    def user_journal_template
      @user_journal_template ||= current_user.journal_template
    end
  end
end
