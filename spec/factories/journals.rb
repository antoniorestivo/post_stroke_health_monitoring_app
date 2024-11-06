FactoryBot.define do
  factory :journal do
    association :journal_template
    description { 'normal day' }
  end
end
