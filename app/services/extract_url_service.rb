# frozen_string_literal: true

class ExtractUrlService
  attr_reader :expression, :links

  def initialize(doc:, depth:)
    @doc = doc
    @depth = depth
    @expression = './/a'
    @links = []
  end

  def call
    fetch_links
  end

  def self.call(doc, depth)
    new(doc: doc, depth: depth).call
  end

  private

  attr_reader :doc

  def fetch_links
    doc.xpath(expression).each do |element|
      data = {}
      link_name = element.text.blank? ? SecureRandom.uuid : element.text
      data[:name] = link_name
      data[:url] = element['href']
      Redis.current.sadd("scraped_links:#{@depth}", data.to_json)
    end
  end
end
