# frozen_string_literal: true

class ScrapesController < ApplicationController
  before_action :set_uri_form

  def new; end

  def create
    @result = CreateUriService.call(@form, scrape_params)
    if @result.success?
      begin_scraping
      flash['message'] = 'We will send you all links to your email'
      redirect_to new_scrape_path
    else
      @form = @result.form
      render 'new'
    end
  end

  private

  def scrape_params
    params.require(:uri).permit(:email, :host, :depth).merge!(user_id: current_user.id)
  end

  def set_uri_form
    @form = UriForm.new(Uri.new)
  end

  def begin_scraping
    @result.scraping_options.stringify_keys!
    ScrapeJob.perform_later(@result.scraping_options)
  end
end
