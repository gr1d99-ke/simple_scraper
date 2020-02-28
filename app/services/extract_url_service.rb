# frozen_string_literal: true

class ExtractUrlService
  attr_reader :expression,
              :links,
              :doc,
              :uri,
              :depth,
              :uri_id,
              :scrape_key,
              :user

  def initialize(doc:, depth:, uri_id:)
    @doc = doc
    @depth = depth
    @expression = './/a'
    @uri_id = uri_id
    @uri = Uri.find(uri_id)
    @user = uri.user
    @scrape_key = "scraped_links:#{depth}:#{uri_id}"
  end

  def call
    fetch_links
  end

  def self.call(doc, depth, uri_id)
    new(doc: doc, depth: depth, uri_id: uri_id).call
  end

  private

  def fetch_links
    counter = 0
    doc.xpath(expression).each do |element|
      extracted_link = element['href']

      LinksExtractionChannel.broadcast_to(user, count: counter)

      next if extracted_link.nil?

      if extracted_link.starts_with?('/')
        extracted_link = uri.host + extracted_link
      end

      Redis.current.sadd(scrape_key, extracted_link)
      counter += 1
    end
  end
end
