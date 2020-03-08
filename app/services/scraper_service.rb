# frozen_string_literal: true

module ScraperService
  class << self
    def call(uri_id, depth)
      uri = uri_model { |klass| klass.find(uri_id) }
      storage_key = "scraped_links:#{depth}:#{uri.id}"
      document = nokogiri_doc(uri.host)

      extract_all(document, depth, uri_id)

      go_deeper(depth, storage_key, uri_id) if depth.positive?

      create_scraped_uri(uri, depth) do |scraped_uri|
        scraped_uri.update(
          links: { total: RedisService.call.scard(storage_key) }
        )
      end

      csv_path = UrlsCsvService.call(depth, uri.id)
      mail_csv_to_user do |job|
        job.perform_later(to: uri.user.email, file_path: csv_path)
      end

      cleanup_redis { |redis| redis.del(storage_key) }
    end

    private

    def go_deeper(depth, storage_key, uri_id)
      (0...depth).each do
        RedisService.call.smembers(storage_key).each do |url|
          doc = nokogiri_doc(url)
          extract_all(doc, depth, uri_id)
        end
      end
    end

    def mail_csv_to_user(job_klass = SendLinksResultsJob, &block)
      block.call(job_klass)
    end

    def create_scraped_uri(uri, depth, &block)
      scraped_uri = uri.scraped_uris.create(user: uri.user, depth: depth)

      block.call(scraped_uri)
    end

    def cleanup_redis(&block)
      block.call(RedisService.call)
    end

    def uri_model(&block)
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
