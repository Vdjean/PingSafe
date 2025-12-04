class BroadcastPingJob < ApplicationJob
  queue_as :default

  def perform(ping)
    ActionCable.server.broadcast("pings_channel", {
      action: "create",
      ping: {
        id: ping.id,
        latitude: ping.latitude.to_f,
        longitude: ping.longitude.to_f,
        comment: ping.comment,
        date: ping.date,
        heure: ping.heure,
        user_id: ping.user_id,
        created_at: ping.created_at.iso8601,
        expires_at: (ping.created_at + 15.minutes).iso8601
      }
    })
  end
end
