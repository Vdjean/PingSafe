class Level < ApplicationRecord
  has_many :user_levels, dependent: :destroy
  has_many :users, through: :user_levels

  validates :points, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :points, uniqueness: true
end
