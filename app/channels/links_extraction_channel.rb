class LinksExtractionChannel < ApplicationCable::Channel
  def subscribed
    stream_from "l"
  end

  def unsubscribed
    stop_all_streams
  end
end
