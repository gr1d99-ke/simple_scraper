# frozen_string_literal: true

class ScrapeJob < ApplicationJob
  queue_as :default

  def perform(options = {})
    scrape_depth = options["depth"].to_i

    cleanup_scraped_links

    uri = Uri.find(options["uri_id"])
    document = NokogiriService.call(url: uri.host)
    ExtractUrlService.call(document, 0)

    if scrape_depth.zero?
      file_path = UrlsCsvService.generate(0)
      SendLinksResultsJob.perform_later(to: uri.user.email, file_path: file_path)
    elsif scrape_depth.equal?(1)
      Redis.current.smembers("scraped_links:0").each do |member|
        next unless Urls.url_valid?(JSON.parse(member)["url"])

        begin
          document = NokogiriService.call(url: JSON.parse(member)["url"])
        rescue Faraday::ConnectionFailed
          next
        end

        ExtractUrlService.call(document, scrape_depth)
      end

      file_path = UrlsCsvService.generate(scrape_depth)
      SendLinksResultsJob.perform_later(to: uri.user.email, file_path: file_path)
    end

    cleanup_scraped_links
  end

  private

  def cleanup_scraped_links
    redis_keys = Redis.current.keys("scraped_links:*")

    if redis_keys.size > 0
      Redis.current.del(redis_keys)
    end
  end
end
