FactoryBot.define do
  factory :health_metric do
    journal_template
    metric_name { "steps" }
    metric_data_type { "integer" }
    metric_unit_name { "steps" }
  end
end
