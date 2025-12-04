# DÉSACTIVÉ TEMPORAIREMENT - Check proximity for push notifications
# class CheckProximityJob < ApplicationJob
#   queue_as :default
#
#   def perform(user_id, latitude, longitude)
#     user = User.find_by(id: user_id)
#     return unless user
#
#     # Find visible pings within 500m (0.5 km)
#     nearby_pings = Ping.visible.near([latitude, longitude], 0.5, units: :km)
#
#     nearby_pings.each do |ping|
#       # Skip user's own pings
#       next if ping.user_id == user_id
#
#       # Skip if already notified
#       next if ProximityNotification.exists?(user_id: user_id, ping_id: ping.id)
#
#       # Create notification record
#       ProximityNotification.create!(
#         user_id: user_id,
#         ping_id: ping.id,
#         notified_at: Time.current
#       )
#
#       # Send push notification
#       SendPushNotificationJob.perform_later(user_id, ping.id, latitude, longitude)
#     end
#   end
# end
