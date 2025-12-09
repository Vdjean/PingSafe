class Ping < ApplicationRecord
  belongs_to :user
  has_one :chat, dependent: :destroy
  has_many :proximity_notifications, dependent: :destroy

  # Active la méthode .near() de Geocoder pour les requêtes de proximité
  reverse_geocoded_by :latitude, :longitude

  validates :date, presence: true
  validates :heure, presence: true
  validates :latitude, presence: true
  validates :longitude, presence: true

  scope :active, -> { where("created_at > ?", 15.minutes.ago) }
  scope :shared, -> { where.not(shared_at: nil) }
  scope :visible, -> { active.shared }

  attr_accessor :nombre_personnes, :signe_distinctif

  before_save :combine_form_fields
  before_save :fetch_address_from_coordinates

  after_update_commit :broadcast_if_shared

  def formatted_address
    # Return coordinates if no lat/long
    return "#{latitude.round(4)}, #{longitude.round(4)}" if latitude.blank? || longitude.blank?

    # If we have a stored address, parse it to extract short format
    if address.present?
      return parse_short_address(address)
    end

    # Otherwise return coordinates
    "#{latitude.round(4)}, #{longitude.round(4)}"
  end

  private

  def parse_short_address(full_address)
    parts = full_address.split(',').map(&:strip)

    zip = parts.find { |p| p =~ /^\d{5}$/ }

    if parts.length >= 2
      # Combine first two parts for full street address (number + street name)
      street = [parts[0], parts[1]].compact.join(' ')

      # Find city (Paris or arrondissement)
      city = parts.find { |p| p =~ /Paris|^\d+e Arrondissement/ } || parts[-3]

      result = [street, city, zip].compact.join(", ")
      return result if result.present?
    end

    # Fallback to coordinates
    "#{latitude.round(4)}, #{longitude.round(4)}"
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
    NotifyNearbyUsersJob.perform_later(id)
  end

  def fetch_address_from_coordinates
    return if latitude.blank? || longitude.blank?
    return if address.present? # Don't re-fetch if already has address

    begin
      url = "https://nominatim.openstreetmap.org/reverse?format=json&lat=#{latitude}&lon=#{longitude}&zoom=18&addressdetails=1"
      response = HTTParty.get(url, headers: { 'User-Agent' => 'PingSafe App' })

      if response.success? && response['display_name']
        self.address = response['display_name']
      end
    rescue => e
      Rails.logger.error "Error fetching address: #{e.message}"
      # Don't fail the save if address fetch fails
    end
  end
end
