# frozen_string_literal: true

module CreateUriService
  def self.call(form, params = {})
    params.merge!(name: SecureRandom.uuid)
    if form.validate(params)
      form.save
      begin_scraping(uri_id: form.model.id, depth: params[:depth])
      result(success?: true, form: form)
    else
      result(success?: false, form: form)
    end
  end

  def self.begin_scraping(options = {})
    options.stringify_keys!
    ScrapeJob.perform_later(options)
  end

  def self.result(options = {})
    OpenStruct.new(options)
  end
end
