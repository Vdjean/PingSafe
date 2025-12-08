# Job pour envoyer une notification push Web à un utilisateur
# Utilise la gem web-push avec les clés VAPID
class SendPushNotificationJob < ApplicationJob
  queue_as :default

  def perform(user_id, ping_id, user_lat, user_lng)
    user = User.find_by(id: user_id)
    ping = Ping.find_by(id: ping_id)
    return unless user && ping

    # Calcule la distance en mètres
    distance = Geocoder::Calculations.distance_between(
      [user_lat, user_lng],
      [ping.latitude, ping.longitude],
      units: :km
    ) * 1000

    payload = {
      title: "Alerte PingSafe",
      body: "Un signalement a été fait à #{distance.round}m de votre position",
      url: "/pings/#{ping.id}",
      ping_id: ping.id
    }

    # Envoie à tous les appareils de l'utilisateur
    user.push_subscriptions.find_each do |subscription|
      send_push(subscription, payload)
    end
  end

  private

  # Envoie la notification via WebPush
  def send_push(subscription, payload)
    WebPush.payload_send(
      message: payload.to_json,
      endpoint: subscription.endpoint,
      p256dh: subscription.p256dh_key,
      auth: subscription.auth_key,
      vapid: vapid_keys,
      ssl_timeout: 5,
      open_timeout: 5,
      read_timeout: 5
    )
  rescue WebPush::ExpiredSubscription, WebPush::InvalidSubscription
    # Supprime les abonnements expirés ou invalides
    subscription.destroy
  rescue StandardError => e
    Rails.logger.error "Erreur notification push: #{e.message}"
  end

  # Récupère les clés VAPID depuis les variables d'environnement
  def vapid_keys
    {
      public_key: ENV["VAPID_PUBLIC_KEY"],
      private_key: ENV["VAPID_PRIVATE_KEY"]
    }
  end
end
