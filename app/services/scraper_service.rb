# frozen_string_literal: true

module ScraperService
  class << self
    def call(uri_id, depth)
      uri = uri_instance { |klass| klass.find(uri_id) }
      data_key = "scraped_links:#{depth}:#{uri.id}"
      document = nokogiri_doc(uri.host)

      extract_all(document, depth, uri_id)

      save_scrape(uri, depth) do |scraped_uri|
        scraped_uri.update(
          links: { total: RedisService.call.scard(data_key) }
        )
      end

      mail_results do |job|
        file_path = UrlsCsvService.call(depth, uri.id)
        job.perform_later(to: uri.user.email, file_path: file_path)
      end

      cleanup_redis { |redis| redis.del(data_key) }
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

    def uri_instance(&block)
      block.call(Uri)
    end

    def nokogiri_doc(host)
      NokogiriService.call(url: host)
    end

    def extract_all(doc, depth, uri_id)
      ExtractUrlService.call(doc, depth, uri_id)
    end
  end
end
