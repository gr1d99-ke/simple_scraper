module CreateUriService
  def self.call(form, params)
    if form.validate(name: params[:name], host: params[:host], user_id: params[:user_id])
      form.save
      options = { uri_id: form.model.id, depth: params[:depth] }
      start_scraping(options)
      result(success?: true, form: form)
    else
      result(success?: false, form: form)
    end
  end

  def self.start_scraping(options = {})
    options.stringify_keys!
    ScrapeJob.perform_later(options)
  end

  def self.result(options = {})
    OpenStruct.new(options)
  end
end