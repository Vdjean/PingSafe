class Ping < ApplicationRecord
  belongs_to :user
  has_one :chat, dependent: :destroy

  validates :date, presence: true
  validates :heure, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  # Virtual attributes for form fields
  attr_accessor :nombre_personnes, :signe_distinctif

  # Combine virtual attributes into comment before saving
  before_save :combine_form_fields

  private

  def combine_form_fields
    parts = []
    parts << "Number of persons: #{nombre_personnes}" if nombre_personnes.present?
    parts << "Distinguishing sign: #{signe_distinctif}" if signe_distinctif.present?
    parts << "Comments: #{comment}" if comment.present?

    self.comment = parts.join("\n") if parts.any?
  end
end
