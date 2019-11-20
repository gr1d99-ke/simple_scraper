# frozen_string_literal: true

class ScrapeJob < ApplicationJob
  queue_as :default

  def perform(options = {})
    uri = Uri.find(options["uri_id"])

    document      = NokogiriService.call(url: uri.host)
    initial_links = ExtractUrlService.call(doc: document)
    scraped_uri   = uri.scraped_uris.create(links: { "0": initial_links }, user: uri.user)

    if options["depth"].to_i.zero?
      file_path = UrlsCsvService.generate(links: scraped_uri.links["0"])
      SendLinksResultsJob.perform_later(to: uri.user.email, file_path: file_path)
    elsif options["depth"].to_i.equal?(1)
      initial_extracted_urls = scraped_uri.links["0"].map { |link_data| link_data["url"] }

      initial_extracted_urls.each do |url|
        next unless Urls.url_valid?(url)

        begin
          document = NokogiriService.call(url: url)
        rescue Faraday::ConnectionFailed => e
          next
        end

        extracted_links = ExtractUrlService.call(doc: document)

        if scraped_uri.links["1"].nil?
          scraped_uri.links["1"] = extracted_links
        else
          scraped_uri.links["1"] += extracted_links
        end
      end

      scraped_uri.save

      # let's now clean the links and send cleaned data
      cleaned_saved_urls = []
      all_links = scraped_uri.links["0"] + scraped_uri.links["1"]
      cleaned_links = []

      all_links.each do |saved_link_dict|
        scraped_url = saved_link_dict["url"]
        next if cleaned_saved_urls.include?(scraped_url)

        cleaned_links << saved_link_dict
        cleaned_saved_urls << scraped_url
      end

      file_path = UrlsCsvService.generate(links: cleaned_links)
      SendLinksResultsJob.perform_later(to: uri.user.email, file_path: file_path)
    end
  end
end
