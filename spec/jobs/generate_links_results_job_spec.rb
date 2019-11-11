# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateLinksResultsJob, type: :job do
  subject(:job) do
    GenerateLinksResultsJob.perform_later(url: url, email: email, depth: "1", name: link_name)
  end

  let(:link_name) { SecureRandom.uuid }
  let(:valid_file) { File.read("#{scraper_test_files_path}links.html") }
  let(:document) { NokogiriService.call(url: url) }
  let(:links) { LinksScraperService.call(doc: document) }
  let(:email) { 'test@user.com' }
  let(:url) { 'http://localhost.com/links.html' }

  describe '.perform_later' do
    before do
      stub_custom_request(url: url, body: valid_file)
      stub_custom_request(url: /https:\/\/example.com\//, body: valid_file)
    end

    it 'queues job' do
      expect { job }.to have_enqueued_job(GenerateLinksResultsJob).with(url: url, email: email, depth: "1", name: link_name)
    end

    it 'generates links.csv file' do
      perform_enqueued_jobs do
        job
        expect(File.exist?("#{storage_path}links.csv")).to be_truthy
      end
    end
  end
end
