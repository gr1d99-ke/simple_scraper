# frozen_string_literal: true

class GenerateLinksResultsJob < ApplicationJob
  queue_as :default

  def perform(url:, email:, depth:, name:)
    document = NokogiriService.call(url: url)
    initial_links = LinksScraperService.call(doc: document)

    saved_link = Link.create(name: name, visited: { "0": initial_links })

    if depth.to_i.zero?
      visited_links = Link.find_by(name: name).visited
      file_path = GenerateLinksResultsService.call(links: visited_links["0"])
      SendLinksResultsJob.perform_later(to: email, file_path: file_path)
    elsif depth.to_i.equal?(1)
      initial_temp_visited_links = saved_link.visited
      link = Link.find_by(name: name)
      visited_links = link.visited["0"]
      initial_extracted_urls = visited_links.map { |link_data| link_data["url"] }
      initial_extracted_urls.each do |url|
        begin
          document = NokogiriService.call(url: url)
        rescue Faraday::ConnectionFailed => e
          p "@" * 100
          p e
          p "@" * 100
          next
        end
        extracted_links = LinksScraperService.call(doc: document)

        if initial_temp_visited_links["1"].nil?
          initial_temp_visited_links["1"] = extracted_links
        else
          initial_temp_visited_links["1"] += extracted_links
        end
      end

      link.update(visited: initial_temp_visited_links)

      # let's now clean the links and send cleaned data
      cleaned_saved_urls = []
      all_links = link.visited["0"] + link.visited["1"]
      cleaned_links = []
      all_links.each do |saved_link_dict|
        scraped_url = saved_link_dict["url"]
        next if cleaned_saved_urls.include?(scraped_url)
        cleaned_links << saved_link_dict
        cleaned_saved_urls << scraped_url
      end

      file_path = GenerateLinksResultsService.call(links: cleaned_links)
      SendLinksResultsJob.perform_later(to: email, file_path: file_path)
    end
  end
end
