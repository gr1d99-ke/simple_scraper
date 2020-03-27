# frozen_string_literal: true

if Rails.env.production?
  uri = URI.parse(ENV['REDISTOGO_URL'])
  Sidekiq.configure_server do |config|
    config.redis = { url: uri }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: uri }
  end
end
