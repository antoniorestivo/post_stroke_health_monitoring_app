FactoryBot.define do
  factory :user do
    first_name { 'Joe' }
    last_name  { 'Bloe' }
    email      { Faker::Internet.email }
    password   { 'long_enough_password' }

    email_confirmed { true }
    confirmed_at    { Time.current }
    confirmation_token { nil }
  end

  factory :unconfirmed_user do
    first_name { 'Joe' }
    last_name  { 'Bloe' }
    email      { Faker::Internet.email }
    password   { 'long_enough_password' }

    email_confirmed   { false }
    confirmed_at      { nil }
    confirmation_token { SecureRandom.hex(20) }
  end
end