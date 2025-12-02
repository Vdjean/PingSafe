class Ping < ApplicationRecord
  belongs_to :user
  has_one :chat, dependent: :destroy

  validates :date, presence: true
  validates :heure, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true
  
end
