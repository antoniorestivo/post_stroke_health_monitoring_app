module UserCharts
  module Modes
    class HandleMetricFrequency
      attr_reader :user_chart, :journals

      def self.build(user_chart, journals)
        new(user_chart, journals).construct
      end

      def initialize(user_chart, journals)
        @user_chart = user_chart
        @journals = journals
      end

      def construct
        { x: labels, y: counts, thresholds: {} }
      end

      private

      def labels
        @labels ||= values.uniq
      end

      def counts
        labels.map { |v| values.count(v) }
      end

      def values
        @values ||= journals.map { |j| j.metrics[x_label] }.compact
      end

      def x_label
        @x_label ||= user_chart.x_label
      end
    end
  end
end
