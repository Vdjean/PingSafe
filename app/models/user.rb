class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :pings, dependent: :destroy
  has_many :user_levels
  has_many :levels, through: :user_levels
  has_many :user_rewards
  has_many :rewards, through: :user_rewards
end
