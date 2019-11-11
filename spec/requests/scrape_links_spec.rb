# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ScrapeLinks", type: :request do
  describe "POST /scrape_links" do
    let(:url) { "https://example.com/links.html" }
    let(:body) { File.read("#{scraper_test_files_path}links.html") }

    before do
      stub_custom_request(url: url, body: body)
    end

    context "When depth is 0" do
      let(:scrape_links_params) do
        { email: "test@user.com", url: url, depth: "0" }
      end

      it "generates links.txt file" do
        perform_enqueued_jobs do
          post scrape_links_path, params: scrape_links_params
          expect(File.exist?(storage_path)).to be_truthy
        end
      end

      it "sends email" do
        perform_enqueued_jobs do
          post scrape_links_path, params: scrape_links_params
          expect(emails.last.to).to eq([scrape_links_params[:email]])
          expect(emails.last.subject).to eq("Scraped links results")
          expect(emails.last.from).to eq(["no-reply@example.com"])
        end
      end

      it "saves scraped links" do
        perform_enqueued_jobs do
          expect { post scrape_links_path, params: scrape_links_params }.to change(Link, :count).from(0).to(1)
        end
      end
    end

    context "When depth is greater than 1" do
      let(:scrape_links_params) do
        { email: "test@user.com", url: url, depth: "1" }
      end

      before do
        stub_custom_request(url: /https:\/\/example.com\//, body: body)
      end

      it "generates links.txt file" do
        perform_enqueued_jobs do
          post scrape_links_path, params: scrape_links_params
          expect(File.exist?(storage_path)).to be_truthy
        end
      end

      it "sends email" do
        perform_enqueued_jobs do
          post scrape_links_path, params: scrape_links_params
          expect(emails.last.to).to eq([scrape_links_params[:email]])
          expect(emails.last.subject).to eq("Scraped links results")
          expect(emails.last.from).to eq(["no-reply@example.com"])
        end
      end

      it "saves scraped links" do
        perform_enqueued_jobs do
          expect { post scrape_links_path, params: scrape_links_params }.to change(Link, :count).from(0).to(1)
        end
      end
    end
  end
end
