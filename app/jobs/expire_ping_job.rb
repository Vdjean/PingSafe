class ExpirePingJob < ApplicationJob
  queue_as :default

  def perform(ping_id)
    ActionCable.server.broadcast("pings_channel", {
      action: "expire",
      ping_id: ping_id
    })
  end
end
