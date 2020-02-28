# frozen_string_literal: true

module CreateUriService
  class << self
    def call(form, params = {})
      setup_params!(params)

      if form.validate(params)
        form.save

        begin_scraping(uri_id: form.model.id, depth: params[:depth])

        result do |res|
          res[:success?] = true
          res[:form] = form
          res
        end
      else

        result do |res|
          res[:success?] = false
          res[:form] = form
          res
        end
      end
    end

    def begin_scraping(options = {})
      options.stringify_keys!
      ScrapeJob.perform_later(options)
    end

    def result(&block)
      block.call(OpenStruct.new)
    end

    private

    def setup_params!(params)
      params.merge!(name: SecureRandom.uuid)
    end
  end
end
