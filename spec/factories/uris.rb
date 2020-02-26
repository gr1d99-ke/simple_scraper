# frozen_string_literal: true

FactoryBot.define do
  factory :uri do
    user
    name { Faker::FunnyName.name }
    host { Faker::Internet.url('example.com', nil, 'https') }
  end
end
