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

  POINTS_PER_SHARE = 10

  def current_level
    return 1 if score.nil? || score == 0

    level_thresholds = Level.order(points: :asc).pluck(:points)
    level_thresholds.reverse.each_with_index do |threshold, index|
      return level_thresholds.length - index if score >= threshold
    end
    1
  end

  def level_name
    "Level #{current_level}"
  end

  def add_share_points!
    old_level = current_level
    self.score ||= 0
    self.score += POINTS_PER_SHARE
    save!(validate: false)

    new_level = current_level
    leveled_up = new_level > old_level

    if leveled_up
      level_record = Level.order(points: :asc).limit(new_level).last
      UserLevel.find_or_create_by!(user: self, level: level_record) do |ul|
        ul.level_name = level_name
      end
    end

    { points_earned: POINTS_PER_SHARE, new_score: score, new_level: new_level, leveled_up: leveled_up }
  end
end
