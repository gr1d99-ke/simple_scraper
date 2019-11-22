# frozen_string_literal: true

class ScrapeJob < ApplicationJob
  queue_as :default

  def perform(options = {})
    scrape_depth = options["depth"].to_i

    uri = Uri.find(options["uri_id"])

    document = NokogiriService.call(url: uri.host)
    ExtractUrlService.call(document, 0, uri.id)

    if scrape_depth.zero?
      uri.scraped_uris.create(user: uri.user, depth: scrape_depth, links: { total: Redis.current.scard("scraped_links:#{scrape_depth}:#{uri.id}") })
      file_path = UrlsCsvService.generate(0, uri.id)
      Redis.current.del("scraped_links:#{scrape_depth}:#{uri.id}")
      SendLinksResultsJob.perform_later(to: uri.user.email, file_path: file_path)
    elsif scrape_depth.equal?(1)
      scraped_uri = uri.scraped_uris.create(user: uri.user, depth: scrape_depth, links: { total: Redis.current.scard("scraped_links:0:#{uri.id}") })

      Redis.current.smembers("scraped_links:0:#{uri.id}").each do |url|
        if Urls.url_valid?(url) == false
          if url.start_with?("/")
            new_url = uri.host + url
            connection = Faraday.new(
              url: new_url,
              ssl: { verify: false }
            )
            response = connection.head
            logger.debug "SCRAPER: URL: #{new_url} STATUS: #{response.status}"
          end

          next
        end

        begin
          document = NokogiriService.call(url: url)
        rescue Faraday::ConnectionFailed => e
          logger.debug "URL: #{url} MESSAGE: #{e.message}\n#{e.backtrace.join("\n")}"
          next
        end

        ExtractUrlService.call(document, scrape_depth, uri.id)
      end

      scraped_uri.update(links: scraped_uri.links.merge(total: Redis.current.scard("scraped_links:#{scrape_depth}:#{uri.id}")))
      file_path = UrlsCsvService.generate(scrape_depth, uri.id)
      Redis.current.del("scraped_links:0:#{uri.id}")
      Redis.current.del("scraped_links:#{scrape_depth}:#{uri.id}")
      SendLinksResultsJob.perform_later(to: uri.user.email, file_path: file_path)
    end
  end
end
