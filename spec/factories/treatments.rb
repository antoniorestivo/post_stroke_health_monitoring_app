FactoryBot.define do
  factory :treatment do
    association :condition
    description { "Sample Treatment" }
  end
end
