# frozen_string_literal: true

require "rails_helper"

RSpec.describe "ScrapeLinks", type: :request do
  describe "POST /scrape_links" do
    let(:url) { "https://example.com/links.html" }
    let(:body) { File.read("#{scraper_test_files_path}links.html") }

    before do
      stub_custom_request(url: url, body: body)
    end

    context "when params are not valid" do
      let(:params) { { uri: {} } }

      context "when host is blank" do
        before { params[:uri].merge!(email: "test@user.com", depth: 0, host: "") }

        it "does not create uri" do
          expect { post scrapes_path, params: params }.not_to change(Uri, :count)
        end

        it "creates user" do
          expect { post scrapes_path, params: params }.to change(User, :count)
        end
      end

      context "when email is blank" do
        before { params[:uri].merge!(host: "https://www.gmail.com", depth: 0, email: "") }

        it "does not create uri" do
          expect { post scrapes_path, params: params }.not_to change(Uri, :count)
        end

        it "does not create user" do
          expect { post scrapes_path, params: params }.not_to change(User, :count)
        end

        it "flashes notice" do
          post scrapes_path, params: params
          expect(response.body).to include("Your email is required")
        end
      end
    end

    context "When depth is 0" do
      let(:scrape_links_params) do
        { uri: { email: "test@user.com", host: url, depth: "0" } }
      end

      it "generates links.txt file" do
        perform_enqueued_jobs do
          post scrapes_path, params: scrape_links_params
          expect(File.exist?(storage_path)).to be_truthy
        end
      end

      it "sends email" do
        perform_enqueued_jobs do
          post scrapes_path, params: scrape_links_params
          expect(emails.last.to).to eq([scrape_links_params[:uri][:email]])
          expect(emails.last.subject).to eq("Scraped links results")
          expect(emails.last.from).to eq(["no-reply@example.com"])
        end
      end

      it "does not save user when the email does not exist" do
        post scrapes_path, params: scrape_links_params
        expect { post scrapes_path, params: scrape_links_params }.not_to change(User, :count)
      end

      it "saves scraped scraped uri" do
        perform_enqueued_jobs do
          expect { post scrapes_path, params: scrape_links_params }.to change(ScrapedUri, :count).from(0).to(1)
        end
      end
    end

    context "When depth is greater than 1" do
      let(:scrape_links_params) do
        { uri: { email: "test@user.com", host: url, depth: "1" } }
      end

      before do
        stub_custom_request(url: /https:\/\/example.com\//, body: body)
      end

      it "generates links.txt file" do
        perform_enqueued_jobs do
          post scrapes_path, params: scrape_links_params
          expect(File.exist?(storage_path)).to be_truthy
        end
      end

      it "sends email" do
        perform_enqueued_jobs do
          post scrapes_path, params: scrape_links_params
          expect(emails.last.to).to eq([scrape_links_params[:uri][:email]])
          expect(emails.last.subject).to eq("Scraped links results")
          expect(emails.last.from).to eq(["no-reply@example.com"])
        end
      end

      it "saves scraped links" do
        perform_enqueued_jobs do
          expect { post scrapes_path, params: scrape_links_params }.to change(ScrapedUri, :count).from(0).to(1)
          expect(ScrapedUri.last.links.keys).to eq(["0", "1"])
        end
      end
    end
  end
end
