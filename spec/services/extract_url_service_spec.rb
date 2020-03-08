# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExtractUrlService, type: :service do
  let(:valid_file) { File.read("#{scraper_test_files_path}links.html") }
  let(:uri) { FactoryBot.create(:uri, host: 'http://example.com') }
  let(:scraped_uri) { FactoryBot.create(:scraped_uri, uri: uri) }

  describe '.call' do
    before do
      stub_custom_request(
        url: 'http://example.com/links.html',
        body: valid_file
      )
    end

    it 'stores links to redis set' do
      document = NokogiriService.call(url: 'http://example.com/links.html')
      described_class.call(document, scraped_uri.depth, scraped_uri.uri.id)
      expect(Redis.current.smembers("scraped_links:#{scraped_uri.depth}:#{scraped_uri.uri.id}").blank?).to be_falsey
    end
  end
end
