# Job pour vérifier si un utilisateur est proche d'un ping actif
# Déclenché à chaque mise à jour de position de l'utilisateur
class CheckProximityJob < ApplicationJob
  queue_as :default

  # Rayon de détection en km (300m = 0.3km)
  PROXIMITY_RADIUS_KM = 0.3

  def perform(user_id, latitude, longitude)
    user = User.find_by(id: user_id)
    return unless user

    # Trouve les pings visibles dans un rayon de 300m
    nearby_pings = Ping.visible.near([latitude, longitude], PROXIMITY_RADIUS_KM, units: :km)

    nearby_pings.each do |ping|
      # Ne pas notifier l'utilisateur pour ses propres pings
      next if ping.user_id == user_id

      # Ne pas re-notifier si déjà notifié pour ce ping
      next if ProximityNotification.exists?(user_id: user_id, ping_id: ping.id)

      # Enregistre la notification pour éviter les doublons
      ProximityNotification.create!(
        user_id: user_id,
        ping_id: ping.id,
        notified_at: Time.current
      )

      # Envoie la notification push
      SendPushNotificationJob.perform_later(user_id, ping.id, latitude, longitude)
    end
  end
end
