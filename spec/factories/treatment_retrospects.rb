FactoryBot.define do
  factory :treatment_retrospect do
    association :treatment
    rating { 4 }
  end
end
