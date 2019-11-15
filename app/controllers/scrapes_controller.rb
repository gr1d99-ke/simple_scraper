# frozen_string_literal: true

class ScrapesController < ApplicationController
  def new
    @form = UriForm.new(Uri.new)
  end

  def create
    if Urls.url_valid?(scrape_params[:host])
      options = { url: scrape_params[:host], email: scrape_params[:email], depth: scrape_params[:depth], name: SecureRandom.uuid }.stringify_keys!
      ScrapeJob.perform_later(options)
      flash['message'] = 'We will notify and send you all links via the email you provided shortly'
      redirect_to new_scrape_path
    else
      flash.now[:alert] = "The link you provided is not valid, check and try again"
      render 'new'
    end
  end

  private

  def scrape_params
    params.require(:uri).permit(:email, :host, :depth)
  end
end
