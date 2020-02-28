# frozen_string_literal: true

module CreateUriService
  class << self
    def call(form, params = {})
      setup_params!(params)

      if form.validate(params)
        form.save

        return_value do |result|
          result[:success?] = true
          result[:form] = form
          result[:scraping_options] = {
            uri_id: form.model.id,
            depth: params[:depth]
          }
          result
        end
      else

        return_value do |result|
          result[:success?] = false
          result[:form] = form
          result
        end
      end
    end

    def return_value(&block)
      block.call(OpenStruct.new)
    end

    private

    def setup_params!(params)
      params.merge!(name: SecureRandom.uuid)
    end
  end
end
