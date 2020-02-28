# frozen_string_literal: true

require "csv"

class UrlsCsvService
  attr_reader :storage_path, :csv_file, :depth, :uri_id

  def initialize(depth, uri_id)
    @storage_path = Rails.root.join('public/links/')
    @csv_file = "#{storage_path}links.csv"
    @depth = depth
    @uri_id = uri_id
  end

  def write_to_csv
    FileUtils.mkdir_p(storage_path) unless File.exist?(storage_path)
    ::CSV.open(csv_file, 'wb') do |csv|
      csv << %i[Url]
      Redis.current.smembers("scraped_links:#{@depth}:#{@uri_id}").each do |url|
        csv << [url]
      end
    end
    csv_file if File.exist?(csv_file)
  end

  def self.call(depth, uri_id)
    new(depth, uri_id).write_to_csv
  end
end
