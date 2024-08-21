module Api
  class JournalTemplatesController < ApplicationController
    def new
    end

    def create
      journal_template = JournalTemplate.create(user: current_user)
      field_names.each do |field_name, v|
        id = field_name.scan(/\d+/).first
        field_unit = permitted_params["field_unit_#{id}"]
        field_data_type = permitted_params["field_data_type_#{id}"]
        warning_threshold = permitted_params['warning_threshold']
        HealthMetric.create(journal_template: journal_template, metric_name: v, metric_data_type: field_data_type,
                            metric_unit_name: field_unit, warning_threshold: warning_threshold)
      end
    end
    def edit
      template_id = params[:id]
      @template = JournalTemplate.find(template_id)
      if @template.user == current_user
        render "edit.json.jb"
      else
        render json: {errors: "Unauthorized"}, status: 422
      end
    end

    def update
      template_id = params[:id]
      @template = JournalTemplate.find(template_id)
      @template.health_metrics.destroy_all
      permitted_params["metrics"].each do |metric|
        values = metric.slice("metric_name","metric_data_type","metric_unit_name", "warning_threshold")
        HealthMetric.create(journal_template_id: template_id, **values)
      end
    end

    private

    def permitted_params
      @permitted_params ||= params.require(:template).permit(*fields, metrics: ["id","journal_template_id",
                                                                                "metric_name","metric_data_type",
                                                                                "metric_unit_name","created_at",
                                                                                "updated_at", "warning_threshold"])

      
    end

    def field_names
      permitted_params.select { |k, v| k.match?(/field_name_\d/) && v.present? }
    end

    def fields
      regex_pattern = /field_(name|unit|data_type)_\d/
      params[:template].keys.select { |k| k.match?(regex_pattern) }
    end
    def user_journal_template
      @user_journal_template ||= current_user.journal_template
    end
  end
end
