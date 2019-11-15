# frozen_string_literal: true

class ScrapesController < ApplicationController
  def scrape_links

    flash['message'] = 'We will notify and send you all links via the email you provided shortly'

    redirect_to root_path
  end

  def new
    @form = UriForm.new(Uri.new)
  end

  def create
    if valid_url?
      options = { url: link_params[:host], email: link_params[:email], depth: link_params[:depth], name: SecureRandom.uuid }.stringify_keys!
      ScrapeJob.perform_later(options)
      flash['message'] = 'We will notify and send you all links via the email you provided shortly'
      redirect_to new_scrape_path
    else
      flash.now[:alert] = "The link you provided is not valid, check and try again"
      render 'new'
    end
  end

  private

  def link_params
    params.require(:uri).permit(:email, :host, :depth)
  end

  def valid_url?
    return false if link_params[:host].nil?

    dirty_url = link_params[:host]
    parsed_url = URI.parse(dirty_url)

    parsed_url.is_a?(URI::HTTP) && parsed_url.host.present?
  rescue URI::InvalidURIError
    false
  end
end
