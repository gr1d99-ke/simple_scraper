module Urls
  def self.url_valid?(url)
    parsed_url = URI.parse(url)
    parsed_url.is_a?(URI::HTTP) && parsed_url.host.present?
  rescue URI::InvalidURIError
    false
  end
end
