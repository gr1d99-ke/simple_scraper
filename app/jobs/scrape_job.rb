# frozen_string_literal: true

class ScrapeJob < ApplicationJob
  queue_as :default

  def perform(options = {})
    document      = NokogiriService.call(url: options["url"])
    initial_links = ExtractUrlService.call(doc: document)
    saved_link    = Link.create(name: options["name"], visited: { "0": initial_links })

    if options["depth"].to_i.zero?
      file_path = UrlsCsvService.generate(links: saved_link.visited["0"])
      SendLinksResultsJob.perform_later(to: options["email"], file_path: file_path)
    elsif options["depth"].to_i.equal?(1)
      initial_extracted_urls = saved_link.visited["0"].map { |link_data| link_data["url"] }

      initial_extracted_urls.each do |url|
        next unless Urls.url_valid?(url)

        begin
          document = NokogiriService.call(url: url)
        rescue Faraday::ConnectionFailed => e
          next
        end

        extracted_links = ExtractUrlService.call(doc: document)

        if saved_link.visited["1"].nil?
          saved_link.visited["1"] = extracted_links
        else
          saved_link.visited["1"] += extracted_links
        end
      end

      saved_link.save

      # let's now clean the links and send cleaned data
      cleaned_saved_urls = []
      all_links = saved_link.visited["0"] + saved_link.visited["1"]
      cleaned_links = []

      all_links.each do |saved_link_dict|
        scraped_url = saved_link_dict["url"]
        next if cleaned_saved_urls.include?(scraped_url)

        cleaned_links << saved_link_dict
        cleaned_saved_urls << scraped_url
      end

      file_path = UrlsCsvService.generate(links: cleaned_links)
      SendLinksResultsJob.perform_later(to: options["email"], file_path: file_path)
    end
  end
end
