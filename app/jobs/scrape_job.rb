# frozen_string_literal: true

class ScrapeJob < ApplicationJob
  queue_as :default

  def perform(options = {})
    depth = options['depth'].to_i
    ScraperService.call(options['uri_id'], depth)
  end
end
