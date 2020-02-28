# frozen_string_literal: true

module CreateUriService
  class << self
    def call(form, params = {})
      setup_params!(params)

      if form.validate(params)
        form.save

        begin_scraping(uri_id: form.model.id, depth: params[:depth])

        result(success?: true, form: form)
      else

        result(success?: false, form: form)
      end
    end

    def begin_scraping(options = {})
      options.stringify_keys!
      ScrapeJob.perform_later(options)
    end

    def result(options = {})
      OpenStruct.new(options)
    end

    private

    def setup_params!(params)
      params.merge!(name: SecureRandom.uuid)
    end
  end
end
