class UserLevel < ApplicationRecord
  belongs_to :users
  belongs_to :levels
end
