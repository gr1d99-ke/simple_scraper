# frozen_string_literal: true

class ScrapesController < ApplicationController
  before_action :set_uri_form

  def new; end

  def create
    @user_service = CreateUserService.call(scrape_params)
    unless @user_service.success?
      flash.now[:alert] = @user_service.error
    end

    uri_params = { name: SecureRandom.uuid, host: scrape_params[:host], user_id: @user_service.model.id, depth: scrape_params[:depth] }

    @create_uri_service = CreateUriService.call(@form, uri_params)
    if @create_uri_service.success?
      flash['message'] = 'We will notify and send you all links via the email you provided shortly'
      redirect_to new_scrape_path
    else
      @form = @create_uri_service.form
      render 'new'
    end
  end

  private

  def scrape_params
    params.require(:uri).permit(:email, :host, :depth)
  end

  def set_uri_form
    @form = UriForm.new(Uri.new)
  end
end
