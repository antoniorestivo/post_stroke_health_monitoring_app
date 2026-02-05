module Api
  class JournalTemplatesController < Api::BaseController
    before_action :set_journal_template, only: [:edit, :update]

    def new
    end

    def create
      journal_template = current_user.build_journal_template
      JournalTemplate.transaction do
        journal_template.save!

        field_names(create_params).each do |field_name, v|
          id = field_name.scan(/\d+/).first
          field_unit = create_params["field_unit_#{id}"]
          field_data_type = create_params["field_data_type_#{id}"]
          warning_threshold = create_params["warning_threshold_#{id}"]
          warning_modifier = create_params["warning_modifier_#{id}"]
          journal_template.health_metrics.create!(metric_name: v, metric_data_type: field_data_type,
                                                  metric_unit_name: field_unit, warning_threshold: warning_threshold,
                                                  warning_modifier: warning_modifier)
        end
      end

      render json: { id: journal_template.id }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
      return
    end

    def edit
      render "edit"
    end

    def update
      if update_params["metrics"].blank?
        return render json: { errors: ["Metrics are required"] }, status: :unprocessable_content
      end

      JournalTemplate.transaction do
        @template.health_metrics.destroy_all
        update_params["metrics"].each do |metric|
          values = metric.slice("metric_name", "metric_data_type", "metric_unit_name", "warning_threshold",
                                "warning_modifier")
          @template.health_metrics.create!(values)
        end
      end

      head :no_content
    rescue ActiveRecord::RecordInvalid => e
      render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
      return
    end

    private

    def set_journal_template
      @template = current_user.journal_template!
    rescue ActiveRecord::RecordNotFound
      render json: { errors: ["Not found"] }, status: :not_found
      return
    end

    def update_params
      @update_params ||= params.require(:template).permit(
        *fields,
        metrics: [
          "metric_name",
          "metric_data_type",
          "metric_unit_name",
          "warning_threshold",
          "warning_modifier"
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

      regex_pattern = /(field_(name|unit|data_type)_\d+)|(warning_threshold_\d+)|(warning_modifier_\d+)/
      params[:template].keys.select { |k| k.match?(regex_pattern) }
    end
  end
end
