class LinksExtractionChannel < ApplicationCable::Channel
  def subscribed
    p current_user
    stream_for current_user
  end

  def unsubscribed
    stop_all_streams
  end
end
