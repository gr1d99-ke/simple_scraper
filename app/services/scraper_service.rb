# frozen_string_literal: true

module ScraperService
  class << self
    def call(uri_id, depth)
      uri = Uri.find(uri_id)
      key = "scraped_links:#{depth}:#{uri.id}"

      save_scrape(uri, depth) do |scraped_uri|
        scraped_uri.update(links: { total: RedisService.call.scard(key) })
      end

      mail_results do |job|
        file_path = UrlsCsvService.call(depth, uri.id)
        job.perform_later(to: uri.user.email, file_path: file_path)
      end

      cleanup_redis { |redis| redis.del(key) }
    end

    private

    def mail_results(job_klass = SendLinksResultsJob, &block)
      block.call(job_klass)
    end

    def save_scrape(uri, depth, &block)
      scraped_uri = uri.scraped_uris.create(user: uri.user, depth: depth)

      block.call(scraped_uri)
    end

    def cleanup_redis(&block)
      block.call(RedisService.call)
    end
  end
end
