# frozen_string_literal: true

require "csv"

class UrlsCsvService
  def initialize(links:)
    @links = links
    @storage_path = Rails.root.join('public/links/')
  end

  def generate
    _generate
  end

  def self.generate(links:)
    new(links: links).generate
  end

  private

  attr_reader :links, :storage_path

  def _generate
    link_file = "#{storage_path}links.csv"
    FileUtils.mkdir_p(storage_path) unless File.exist?(storage_path)
    index = 1
    ::CSV.open("#{storage_path}links.csv", 'wb') do |csv|
      csv << %i[No Name Link]
      links.each do |link|
        csv << [index, link["name"], link["url"]]
        index += 1
      end
    end

    link_file if File.exist?(link_file)
  end
end
