module UserCharts
  module Modes
    class HandleMetricVsMetric
      attr_reader :user_chart, :metrics

      def self.build(user_chart, metrics)
        new(user_chart, metrics).construct
      end

      def initialize(user_chart, metrics)
        @user_chart = user_chart
        @metrics = metrics
      end

      def construct
        { x: x_data, y: y_data, thresholds: find_warning_thresholds, x_unit: x_metric&.metric_unit_name,
          y_unit: y_metric&.metric_unit_name }
      end

      private

      def x_data
        label = user_chart.x_label
        metrics.map { |h| h[label] }
      end

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
        { x: x_metric&.warning_threshold, y: y_metric&.warning_threshold,
          x_modifier: x_metric&.warning_modifier, y_modifier: y_metric&.warning_modifier }
      end
    end
  end
end