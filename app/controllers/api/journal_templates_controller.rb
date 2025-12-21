module Api
  class JournalTemplatesController < Api::BaseController
    before_action :set_journal_template, only: [:edit, :update]
    before_action :authorize_journal_template, only: [:edit, :update]

    def new
    end

    def create
      journal_template = current_user.journal_templates.build
      if journal_template.save
        field_names.each do |field_name, value|
          id = field_name.scan(/\d+/).first
          field_unit = permitted_params["field_unit_#{id}"]
          field_data_type = permitted_params["field_data_type_#{id}"]
          warning_threshold = permitted_params["warning_threshold_#{id}"]

          journal_template.health_metrics.create(
            metric_name: value,
            metric_data_type: field_data_type,
            metric_unit_name: field_unit,
            warning_threshold: warning_threshold
          )
        end

        render json: { id: journal_template.id }, status: :created
      else
        render json: { errors: journal_template.errors.full_messages }, status: :unprocessable_entity
      end
    end

    def edit
      render "edit"
    end

    def update
      if permitted_params["metrics"].blank?
        return render json: { errors: ["Metrics are required"] }, status: :unprocessable_entity
      end

      @template.health_metrics.destroy_all

      permitted_params["metrics"].each do |metric|
        values = metric.slice("metric_name", "metric_data_type", "metric_unit_name", "warning_threshold")
        @template.health_metrics.create(values)
      end

      if @template.errors.empty?
        head :no_content
      else
        render json: { errors: @template.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def set_journal_template
      @template = current_user.journal_templates.find_by(id: params[:id])
      return if @template

      render json: { errors: ["Journal template not found"] }, status: :not_found
    end

    def authorize_journal_template
      return if @template.user_id == current_user.id

      render json: { errors: ["Unauthorized"] }, status: :forbidden
    end

    def permitted_params
      @permitted_params ||= params.require(:template).permit(
        *fields,
        metrics: [
          "metric_name",
          "metric_data_type",
          "metric_unit_name",
          "warning_threshold"
        ]
      )
    end

    def field_names
      permitted_params.select { |k, v| k.match?(/field_name_\d+/) && v.present? }
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