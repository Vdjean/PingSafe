class UserReward < ApplicationRecord
  belongs_to :rewards
  belongs_to :users
end
