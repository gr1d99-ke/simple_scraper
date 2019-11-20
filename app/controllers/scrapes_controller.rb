# frozen_string_literal: true

class ScrapesController < ApplicationController
  before_action :set_uri_form

  def new; end

  def create
    name = SecureRandom.uuid

    @user_form = UserForm.new(User.new)
    if @user_form.validate(email: scrape_params[:email])
      @user_form.save
    elsif @user_form.errors.messages[:email].equal?("has already been taken")
      @user_form = OpenStruct.new(model: User.find(scrape_params[:email]))
    else
      flash.now[:alert] = "Your email is required"
    end

    uri_form_params = { name: name, host: scrape_params[:host], user_id: @user_form.model.id }

    if @form.validate(uri_form_params)
      @form.save
      options = { uri_id: @form.model.id, depth: scrape_params[:depth] }.stringify_keys!
      ScrapeJob.perform_later(options)
      flash['message'] = 'We will notify and send you all links via the email you provided shortly'
      redirect_to new_scrape_path
    else
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
