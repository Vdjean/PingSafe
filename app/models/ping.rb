class Ping < ApplicationRecord
  reverse_geocoded_by :latitude, :longitude

  belongs_to :user
  has_one :chat, dependent: :destroy
  has_many :proximity_notifications, dependent: :destroy

  validates :date, presence: true
  validates :heure, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  scope :active, -> { where("created_at > ?", 15.minutes.ago) }
  scope :shared, -> { where.not(shared_at: nil) }
  scope :visible, -> { active.shared }

  attr_accessor :nombre_personnes, :signe_distinctif

  before_save :combine_form_fields

  after_update_commit :broadcast_if_shared

  private

  def combine_form_fields
    parts = []
    parts << "Number of persons: #{nombre_personnes}" if nombre_personnes.present?
    parts << "Distinguishing sign: #{signe_distinctif}" if signe_distinctif.present?
    parts << "Comments: #{comment}" if comment.present?

    self.comment = parts.join("\n") if parts.any?
  end

  def broadcast_if_shared
    return unless saved_change_to_shared_at? && shared_at.present?

    BroadcastPingJob.perform_later(self)
    ExpirePingJob.set(wait: 15.minutes).perform_later(id)
  end
end
