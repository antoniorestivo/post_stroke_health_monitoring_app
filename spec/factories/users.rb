FactoryBot.define do
  factory :user do
    first_name { 'Joe' }
    last_name { 'Bloe' }
    email { Faker::Internet.email }
    password { 'blah' }
  end
end
