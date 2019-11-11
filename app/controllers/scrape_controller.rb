# frozen_string_literal: true

class ScrapeController < ApplicationController
  def scrape_links
    return redirect_to root_path, alert: "The link you provided is not valid, check and try again" unless valid_url?

    scrape_name_id = "#{URI.parse(link_params[:url]).host.split(".")[0]}-#{SecureRandom.uuid}"

    GenerateLinksResultsJob.perform_later(url: link_params[:url], email: link_params[:email], depth: link_params[:depth], name: scrape_name_id)

    flash['message'] = 'We will notify and send you all links via the email you provided shortly'

    redirect_to root_path
  end

  private

  def link_params
    params.permit(:email, :url, :depth)
  end

  def valid_url?
    return false if link_params[:url].nil?

    dirty_url = link_params[:url]
    parsed_url = URI.parse(dirty_url)

    parsed_url.is_a?(URI::HTTP) && parsed_url.host.present?
  rescue URI::InvalidURIError
    false
  end
end
