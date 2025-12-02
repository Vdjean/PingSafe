class Ping < ApplicationRecord
  belongs_to :user
  has_one :chat, dependent: :destroy
end
