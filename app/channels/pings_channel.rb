class PingsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "pings_channel"
  end

  def unsubscribed
    # Cleanup when channel is unsubscribed
  end
end
