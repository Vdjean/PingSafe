class Ping < ApplicationRecord
  reverse_geocoded_by :latitude, :longitude

  belongs_to :user
  has_one :chat, dependent: :destroy
  has_many :proximity_notifications, dependent: :destroy

  validates :date, presence: true
  validates :heure, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  # Geocoding
  reverse_geocoded_by :latitude, :longitude
  after_validation :reverse_geocode, if: ->(obj) { obj.latitude.present? && obj.longitude.present? && obj.address.blank? }

  # Virtual attributes for form fields
  attr_accessor :nombre_personnes, :signe_distinctif

  before_save :combine_form_fields

  # Get formatted address for display (street, city, zip)
  def formatted_address
    # If address is not yet populated, try to geocode now
    if address.blank? && latitude.present? && longitude.present?
      begin
        result = Geocoder.search([latitude, longitude]).first
        if result
          parts = []
          parts << result.street if result.street.present?
          parts << result.city if result.city.present?
          parts << result.postal_code if result.postal_code.present?
          return parts.join(", ") if parts.any?
        end
      rescue
        # If geocoding fails, fall back to coordinates
      end
      return "#{latitude.round(4)}, #{longitude.round(4)}"
    end

    # Return stored address or coordinates as fallback
    address.presence || "#{latitude.round(4)}, #{longitude.round(4)}"
  end

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
