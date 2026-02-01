module UserCharts
  class Enrich
    attr_reader :user_chart, :journals

    def self.build(user_chart, journals)
      instance = new(user_chart, journals)
      instance.assign_data
    end

    def initialize(user_chart, journals)
      @user_chart = user_chart
      @journals = journals
    end

    def assign_data
      case user_chart.chart_mode
      when "treatment_comparison"
        handle_boxplot
      when "metric_over_time"
        handle_metric_over_time
      when "metric_frequency"
        handle_metric_frequency
      when "metric_vs_metric"
        handle_metric_vs_metric
      else
        raise "Unknown chart mode"
      end
    end

    def data
      if chart_type == 'boxplot'
        handle_boxplot
      else
        { x: refined_x_data, y: refined_y_data, thresholds: find_warning_thresholds }
      end
    end

    private

    def handle_boxplot
      treatment_ids = user_chart.options['treatmentIds']
      retrospects = TreatmentRetrospect.where(treatment_id: treatment_ids).order(treatment_id: :asc)
      UserCharts::TreatmentComparisons::Construct.build(user_chart, retrospects)
    end

    def handle_metric_over_time
      UserCharts::Modes::HandleMetricOverTime.build(user_chart, journals)
    end

    def handle_metric_frequency
      UserCharts::Modes::HandleMetricFrequency.build(user_chart, journals)
    end

    def handle_metric_vs_metric
      UserCharts::Modes::HandleMetricVsMetric.build(user_chart, metrics)
    end

    def refined_x_data
      if chart_type == 'bar'
        x_data.uniq
      else
        x_data
      end
    end

    def refined_y_data
      if x_label == 'Time' && y_data.first.is_a?(String)
        y_data.map.with_index { |_, idx| idx }
      else
        y_data
      end
    end

    def x_data
      if x_label == 'Time'
        journals.map { |j| j.created_at.strftime('%m-%d-%Y') }
      else
        journals.map { |j| j.metrics[x_label] }
      end
    end

    def y_data
      if chart_type == 'bar'
        x_data.map do |value|
          metrics.count { |metric| metric[x_label] == value }
        end
      else
        journals.map { |j| j.metrics[y_label] }
      end
    end

    def x_label
      @x_label ||= user_chart.x_label
    end

    def y_label
      @y_label ||= user_chart.y_label
    end

    def chart_type
      @chart_type ||= user_chart.chart_type
    end

    def health_metrics
      @health_metrics ||= user_chart.health_metrics
    end

    def metric_names
      @metric_names ||= health_metrics.pluck(:metric_name)
    end

    def x_metric
      @x_metric ||= health_metrics.find_by(metric_name: user_chart.x_label)
    end

    def y_metric
      @y_metric ||= health_metrics.find_by(metric_name: user_chart.y_label)
    end

    def find_warning_thresholds
      { x: x_metric&.warning_threshold, y: y_metric&.warning_threshold }
    end

    def metrics
      @metrics ||= journals.pluck(:metrics)
    end
  end
end
