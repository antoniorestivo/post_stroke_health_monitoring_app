module Journals
  class EnrichMetrics
    attr_reader :journals, :template

    def initialize(journals, template)
      @template = template
      @journals = journals
    end

    def with_units
      journal_metrics.transform_values do |hash|
        hash.each_with_object({}) do |(k, v), memo|
          memo[k] = measure_with_unit(k, v)
        end
      end
    end

    def measure_with_unit(key, value)
      "#{value} #{metrics_with_names[key]}"
    end

    def journal_metrics
      journals.pluck(:id, :metrics).to_h
    end

    def metrics
      @metrics ||= template.health_metrics
    end

    def metrics_with_names
      @metrics_with_names ||= metrics.each_with_object({}) do |metric, memo|
        memo[metric.metric_name] = metric.metric_unit_name
      end
    end
  end
end
