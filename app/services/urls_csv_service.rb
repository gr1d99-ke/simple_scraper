# frozen_string_literal: true

require "csv"

class UrlsCsvService
  def initialize(depth, uri_id)
    @storage_path = Rails.root.join('public/links/')
    @depth = depth
    @uri_id = uri_id
  end

  def generate
    _generate
  end

  def self.generate(depth, uri_id)
    new(depth, uri_id).generate
  end

  private

  attr_reader :links, :storage_path

  def _generate
    link_file = "#{storage_path}links.csv"
    FileUtils.mkdir_p(storage_path) unless File.exist?(storage_path)
    ::CSV.open("#{storage_path}links.csv", 'wb') do |csv|
      csv << %i[Url]
      Redis.current.smembers("scraped_links:#{@depth}:#{@uri_id}").each do |url|
        csv << [url]
      end
    end

    link_file if File.exist?(link_file)
  end
end
