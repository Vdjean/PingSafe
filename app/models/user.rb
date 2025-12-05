class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :pings, dependent: :destroy
  has_many :user_levels
  has_many :levels, through: :user_levels
  has_many :user_rewards
  has_many :rewards, through: :user_rewards
  has_many :push_subscriptions, dependent: :destroy
  has_many :proximity_notifications, dependent: :destroy

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }
end
