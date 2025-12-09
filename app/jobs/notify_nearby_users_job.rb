
class NotifyNearbyUsersJob < ApplicationJob
  queue_as :default

  NOTIFICATION_RADIUS_KM = 0.3

  def perform(ping_id)
    ping = Ping.find_by(id: ping_id)
    return unless ping

    subscriptions_with_location = PushSubscription
      .where.not(last_latitude: nil, last_longitude: nil)
      .where("last_location_at > ?", 1.hour.ago)

    subscriptions_with_location.find_each do |subscription|
      next if subscription.user_id == ping.user_id

      distance_km = Geocoder::Calculations.distance_between(
        [subscription.last_latitude, subscription.last_longitude],
        [ping.latitude, ping.longitude],
        units: :km
      )

      next unless distance_km <= NOTIFICATION_RADIUS_KM

      next if ProximityNotification.exists?(user_id: subscription.user_id, ping_id: ping.id)

      ProximityNotification.create!(
        user_id: subscription.user_id,
        ping_id: ping.id,
        notified_at: Time.current
      )

      send_push_notification(subscription, ping, distance_km)
    end
  end

  private

  def send_push_notification(subscription, ping, distance_km)
    distance_meters = (distance_km * 1000).round

    payload = {
      title: "Alerte PingSafe",
      body: "Un signalement a été fait à #{distance_meters}m de votre position",
      url: "/pings/#{ping.id}",
      ping_id: ping.id
    }

    WebPush.payload_send(
      message: payload.to_json,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh_key,
      auth: subscription.auth_key,
      vapid: {
        public_key: ENV["VAPID_PUBLIC_KEY"],
        private_key: ENV["VAPID_PRIVATE_KEY"]
      },
      ssl_timeout: 5,
      open_timeout: 5,
      read_timeout: 5
    )
  rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
    subscription.destroy
  rescue StandardError => e
    Rails.logger.error "Erreur notification push pour subscription #{subscription.id}: #{e.message}"
  end
end
