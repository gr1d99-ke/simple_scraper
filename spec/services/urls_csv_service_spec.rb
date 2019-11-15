# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UrlsCsvService, type: :service do
  describe '.generate' do
    let(:url) { 'http://example.com/links.html' }
    let(:body) { File.read("#{scraper_test_files_path}links.html") }

    it 'generates text file' do
      stub_custom_request(url: url, body: body)
      document = NokogiriService.call(url: url)
      links = ExtractUrlService.call(doc: document)
      links_file = described_class.generate(links: links)
      expect(File.exist?(links_file)).to be_truthy
    end
  end
end
