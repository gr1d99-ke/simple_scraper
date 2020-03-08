# frozen_string_literal: true

class ExtractUrlService
  attr_reader :expression, :links, :doc, :uri, :depth, :uri_id, :storage_key, :user

  def initialize(doc:, depth:, uri_id:)
    @doc = doc
    @depth = depth
    @expression = './/a'
    @uri_id = uri_id
    @uri = Uri.find(uri_id)
    @user = uri.user
    @storage_key = "scraped_links:#{depth}:#{uri_id}"
  end

  def call
    fetch_links
  end

  def self.call(doc, depth, uri_id)
    new(doc: doc, depth: depth, uri_id: uri_id).call
  end

  private

  def fetch_links
    doc.xpath(expression).each do |element|
      extracted_link = normalize_href(element['href'])

      next if extracted_link.nil?

      next unless Urls.url_valid?(extracted_link)

      next if URI.parse(uri.host).host != URI.parse(extracted_link).host

      next if member?(extracted_link)

      store_link do |redis|
        if added?(redis, extracted_link)
          LinksExtractionChannel.broadcast_to(user, count: redis.scard(storage_key))
        end
      end
    end

    self
  end

  def member?(extracted_link)
    # SISMEMBER has a a time complexity of O(1) thus making it efficient to check urls that are already in the set
    RedisService.call.sismember(storage_key, extracted_link)
  end

  def added?(redis, extracted_link)
    # SADD has a time complexity of O(1) also
    redis.sadd(storage_key, extracted_link)
  end

  def normalize_href(href)
    return href if href.nil?

    return uri.host + href if href.starts_with?('/')

    href
  end

  def store_link(&block)
    block.call(RedisService.call)
  end
end
