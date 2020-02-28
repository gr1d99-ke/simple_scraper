# frozen_string_literal: true

class ScrapeJob < ApplicationJob
  queue_as :default

  def perform(options = {})
    scrape_depth = options['depth'].to_i
    uri = uri_instance(options['uri_id'])

    document = NokogiriService.call(url: uri.host)
    ExtractUrlService.call(document, 0, uri.id)

    if scrape_depth.zero?
      ScraperService.call(options['uri_id'], scrape_depth)
    elsif scrape_depth.equal?(1)
      scraped_uri = save_scrape(uri, scrape_depth) do |scraped_uri|
        scraped_uri.links = { total: Redis.current.scard("scraped_links:0:#{uri.id}") }
        scraped_uri.save
        scraped_uri
      end

      RedisService.call do |redis|
        redis.smembers("scraped_links:0:#{uri.id}").each do |url|
          unless Urls.url_valid?(url)
            next unless url.start_with?('/')

            new_url = uri.host + url
            connection = Faraday.new(url: new_url, ssl: { verify: false })
            response = connection.head
            black_listed_status_codes = [404]

            next if black_listed_status_codes.include?(response.status)

            url = new_url
          end

          # ensure domain is the same
          next if URI.parse(uri.host).host != URI.parse(url).host

          begin
            document = NokogiriService.call(url: url)
          rescue Faraday::ConnectionFailed
            next
          end

          ExtractUrlService.call(document, scrape_depth, uri.id)
        end
      end

      scraped_uri.update(
        links: scraped_uri.links.merge(
          total: RedisService.call.scard(
            "scraped_links:#{scrape_depth}:#{uri.id}"
          )
        )
      )

      file_path = UrlsCsvService.call(scrape_depth, uri.id)

      RedisService.call do |redis|
        redis.del("scraped_links:0:#{uri.id}")
        redis.del("scraped_links:#{scrape_depth}:#{uri.id}")
      end

      SendLinksResultsJob.perform_later(to: uri.user.email, file_path: file_path)
    end
  end

  private

  def uri_instance(id)
    Uri.find(id)
  end

  def save_scrape(uri, depth, &block)
    scraped_uri = uri.scraped_uris.create(user: uri.user, depth: depth)

    block.call(scraped_uri)
  end

  def mail_results(mailer_job = SendLinksResultsJob, &block)
    block.call(mailer_job)
  end
end
