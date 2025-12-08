class PingsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "pings_channel"
  end

  def unsubscribed
  end
end
