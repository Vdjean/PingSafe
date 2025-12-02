class Chat < ApplicationRecord
  belongs_to :ping
  has_many :messages, dependent: :destroy
end
