FactoryBot.define do
  factory :user_chart do
    user
    title { "Treatment Comparison Chart" }
    chart_type { "bar" }
    x_label { "Treatments" }
    y_label { "Ratings" }
  end
end
