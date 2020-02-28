# frozen_string_literal: true

class ExtractUrlService
  attr_reader :expression, :links

  def initialize(doc:, depth:, uri_id:)
    @doc = doc
    @depth = depth
    @expression = './/a'
    @uri_id = uri_id
  end

  def call
    fetch_links
  end

  def self.call(doc, depth, uri_id)
    new(doc: doc, depth: depth, uri_id: uri_id).call
  end

  private

  attr_reader :doc

  def fetch_links
    counter = 0
    doc.xpath(expression).each do |element|
      extracted_link = element['href']
      ActionCable.server.broadcast("l", count: counter)
      Redis.current.sadd("scraped_links:#{@depth}:#{@uri_id}", extracted_link)
      counter += 1
    end
  end
end
