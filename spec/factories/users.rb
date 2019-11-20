FactoryBot.define do
  factory :user do
    email { Faker::Internet.email }

    factory :user_with_scraped_uris do
      after(:create) do |user, count = 5|
        uri = FactoryBot.create(:uri, user: user)
        create_list(:scraped_uri, count, user: user, uri: uri)
      end
    end
  end
end
