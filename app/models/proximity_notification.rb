class ProximityNotification < ApplicationRecord
  belongs_to :user
  belongs_to :ping

  validates :notified_at, presence: true
  validates :user_id, uniqueness: { scope: :ping_id, message: "déjà notifié pour ce ping" }
end
