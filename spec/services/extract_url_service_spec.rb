# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ExtractUrlService, type: :service do
  let(:valid_file) { File.read("#{scraper_test_files_path}links.html") }

  describe '.call' do
    before do
      stub_custom_request(
        url: 'http://localhost.com/links.html',
        body: valid_file
      )
    end

    it 'returns an array of links' do
      document = NokogiriService.call(url: 'http://localhost.com/links.html')
      links = described_class.call(doc: document)
      expect(links).to be_a(Array)
    end

    it 'each item in returned array is a dictionary' do
      document = NokogiriService.call(url: 'http://localhost.com/links.html')
      links = described_class.call(doc: document)

      links.each do |link|
        expect(link).to be_a(Hash)
      end
    end

    it 'each item in array has name and href keys' do
      document = NokogiriService.call(url: 'http://localhost.com/links.html')
      links = described_class.call(doc: document)

      links.each do |link|
        expect(link.keys).to match_array(%i[name url])
      end
    end
  end
end
