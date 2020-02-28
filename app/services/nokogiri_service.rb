# frozen_string_literal: true

module NokogiriService
  class << self
    def call(url:)
      response = Faraday.get(url)
      process(body: response.body)
    end

    private

    def process(body:)
      Nokogiri::HTML.fragment(body)
    end
  end
end
