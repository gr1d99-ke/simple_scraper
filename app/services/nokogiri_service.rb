# frozen_string_literal: true

class NokogiriService
  def initialize(url:)
    @url = url
  end

  def call
    connection = Faraday.new(
      url: url,
      ssl: { verify: false }
    )

    body = connection.get.body
    process(body: body)
  end

  def self.call(url:)
    new(url: url).call
  end

  private

  attr_reader :url

  def process(body:)
    Nokogiri::HTML.fragment(body)
  end
end
