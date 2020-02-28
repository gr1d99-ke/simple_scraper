# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UrlsCsvService, type: :service do
  describe '.generate' do
    let(:url)         { 'http://example.com/links.html' }
    let(:body)        { File.read("#{scraper_test_files_path}links.html") }
    let(:scraped_uri) { FactoryBot.create(:scraped_uri) }

    it 'generates text file' do
      stub_custom_request(url: url, body: body)

      document = NokogiriService.call(url: url)
      ExtractUrlService.call(document, scraped_uri.depth, scraped_uri.uri.id)
      links_file = described_class.call(scraped_uri.depth, scraped_uri.uri.id)

      expect(File.exist?(links_file)).to be_truthy
    end
  end
end
