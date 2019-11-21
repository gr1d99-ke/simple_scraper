# frozen_string_literal: true

class ScrapeJob < ApplicationJob
  queue_as :default

  def perform(options = {})
    uri = Uri.find(options["uri_id"])

    document = NokogiriService.call(url: uri.host)
    ExtractUrlService.call(doc: document)

    if options["depth"].to_i.zero?
      file_path = UrlsCsvService.generate
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
      all_links = scraped_uri.links["0"] + scraped_uri.links["1"]
      all_links.each do |saved_link_dict|
        Redis.current.sadd("scraped_links", saved_link_dict)
      end

      file_path = UrlsCsvService.generate
      SendLinksResultsJob.perform_later(to: uri.user.email, file_path: file_path)
    end
  end
end
