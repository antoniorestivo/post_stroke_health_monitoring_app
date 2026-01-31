module UserCharts
  module Modes
    class HandleMetricOverTime
      attr_reader :user_chart, :journals

      def self.build(user_chart, journals)
        new(user_chart, journals).construct
      end

      def initialize(user_chart, journals)
        @user_chart = user_chart
        @journals = journals
      end

      def construct
        { x: x_data, y: y_data, thresholds: find_warning_thresholds }
      end

      private

      def y_data
        label = user_chart.y_label
        metrics.map { |h| h[label] }
      end

      def x_metric
        @x_metric ||= user_chart.health_metrics.find_by(metric_name: user_chart.x_label)
      end

      def y_metric
        @y_metric ||= user_chart.health_metrics.find_by(metric_name: user_chart.y_label)
      end

      def find_warning_thresholds
        { x: nil, y: y_metric&.warning_threshold }
      end

      def x_data
        journals.map { |j| j.created_at.strftime('%m-%d-%Y') }
      end

      def metrics
        @metrics ||= journals.pluck(:metrics)
      end
    end
  end
end