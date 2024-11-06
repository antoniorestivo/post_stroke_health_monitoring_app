FactoryBot.define do
  factory :condition do
    association :user
    name { "Kangaroo Flu" }
    support { true }
    description { 'got it somewhere in Australia' }
  end
end
