# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ScrapeJob, type: :job do
  subject(:job) do
    ScrapeJob.perform_later(job_opts)
  end

  let(:uri)        { FactoryBot.create(:uri, host: 'https://example.com/') }
  let(:valid_file) { File.read("#{scraper_test_files_path}links.html") }
  let(:url)        { 'http://localhost.com/links.html' }
  let(:job_opts)   { { uri_id: uri.id, depth: '1' }.stringify_keys! }

  describe '.perform_later' do
    before do
      stub_custom_request(url: url, body: valid_file)
      stub_custom_request(url: %r{https://example.com/}, body: valid_file)
    end

    it 'queues job' do
      expect { job }.to have_enqueued_job(ScrapeJob).with(job_opts)
    end

    it 'generates links.csv file' do
      perform_enqueued_jobs do
        job
        expect(File.exist?("#{storage_path}links.csv")).to be_truthy
      end
    end
  end
end
