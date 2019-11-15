# frozen_string_literal: true

class SendLinksResultsJob < ApplicationJob
  queue_as :default

  def perform(to:, file_path:)
    LinksMailer.with(to: to, filepath: file_path).send_results.deliver
  end
end
