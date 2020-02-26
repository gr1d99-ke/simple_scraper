# frozen_string_literal: true

FactoryBot.define do
  sequence :email do |n|
    "test-scraper#{n}@example.com"
  end
end
