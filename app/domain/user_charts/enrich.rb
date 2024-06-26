module UserCharts
  class Enrich
    attr_reader :user_chart, :journals

    def initialize(user_chart, journals)
      @user_chart = user_chart
      @journals = journals
    end

    def data
      { x: refined_x_data, y: refined_y_data }
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

    def metrics
      @metrics ||= journals.map(&:metrics)
    end

    def chart_type
      @chart_type ||= user_chart.chart_type
    end
  end
end
