# DÉSACTIVÉ TEMPORAIREMENT - Push subscription model
# class PushSubscription < ApplicationRecord
#   belongs_to :user
#
#   validates :endpoint, presence: true, uniqueness: true
#   validates :p256dh_key, presence: true
#   validates :auth_key, presence: true
#
#   def update_location(latitude, longitude)
#     update(
#       last_latitude: latitude,
#       last_longitude: longitude,
#       last_location_at: Time.current
#     )
#   end
# end
