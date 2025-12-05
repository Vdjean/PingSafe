class SendPushNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, ping_id, user_lat, user_lng)
    user = User.find_by(id: user_id)
    ping = Ping.find_by(id: ping_id)
    return unless user && ping

    # Calculate distance
    distance = Geocoder::Calculations.distance_between(
      [user_lat, user_lng],
      [ping.latitude, ping.longitude],
      units: :km
    ) * 1000 # Convert to meters

    payload = {
      title: "Alerte PingSafe",
      body: "Un signalement a été fait à #{distance.round}m de votre position",
      url: "/pings/#{ping.id}",
      ping_id: ping.id
    }

    user.push_subscriptions.find_each do |subscription|
      send_notification(subscription, payload)
    end
  end

  private

  def send_notification(subscription, payload)
    WebPush.payload_send(
      message: payload.to_json,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh_key,
      auth: subscription.auth_key,
      vapid: {
        public_key: ENV["VAPID_PUBLIC_KEY"],
        private_key: ENV["VAPID_PRIVATE_KEY"]
      }
    )
  rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
    subscription.destroy
  rescue StandardError => e
    Rails.logger.error "Push notification failed: #{e.message}"
  end
end
