module UserCharts
  module TreatmentComparisons
    class Construct
      attr_reader :user_chart, :retrospects

      def self.build(user_chart, retrospects)
        new(user_chart, retrospects).shaped_data
      end

      def initialize(user_chart, retrospects)
        @user_chart = user_chart
        @retrospects = retrospects
      end

      def shaped_data
        { labels: labels, datasets: datasets }
      end

      private

      def labels
        treatment_ids = data.keys
        Treatment.where(id: treatment_ids).order(id: :asc).pluck(:description).map { |str| str.slice(0, 15) }
      end

      def datasets
        [{
           label: 'Treatment Rating Comparison',
           data: data.values,
           backgroundColor: 'rgba(75, 192, 192, 0.2)',
           borderColor: 'rgba(75, 192, 192, 1)',
           borderWidth: 1,
           outlierColor: '#999999',
           padding: 10,
           itemRadius: 0,
         }]
      end

      def data
        @data ||= retrospects.pluck(:treatment_id, :rating).each_with_object({}) do |arr, memo|
          memo[arr[0]] ||= []
          memo[arr[0]] << arr[1]
        end
      end
    end
  end
end
