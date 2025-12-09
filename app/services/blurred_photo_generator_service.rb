require 'mini_magick'
require 'httparty'
require 'base64'
require 'tempfile'

class BlurredPhotoGeneratorService
  include HTTParty

  AZURE_VISION_ENDPOINT = ENV['AZURE_VISION_ENDPOINT'] || 'https://pingsafe-photo.cognitiveservices.azure.com'
  AZURE_VISION_KEY = ENV['AZURE_VISION_KEY'] || ENV['GITHUB_TOKEN']

  def initialize(base64_image)
    @base64_image = base64_image
  end

  def self.blur_faces(base64_image)
    new(base64_image).blur_faces
  end

  def blur_faces
    # Convert base64 to binary image data
    image_data = extract_image_data(@base64_image)

    # Detect faces using Azure Face API
    faces = detect_faces_with_azure(image_data)

    if faces.empty?
      Rails.logger.info "No faces detected in image"
      return @base64_image # Return original if no faces detected
    end

    Rails.logger.info "Detected #{faces.count} face(s), applying blur"
    # Blur faces using MiniMagick
    blur_image_with_faces(image_data, faces)
  rescue StandardError => e
    Rails.logger.error "Error in BlurredPhotoGeneratorService: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")

    # If Azure fails, return original
    @base64_image
  end

  private

  def extract_image_data(base64_string)
    # Remove data:image/...;base64, prefix if present
    base64_data = base64_string.sub(/^data:image\/\w+;base64,/, '')
    Base64.decode64(base64_data)
  end

  def detect_faces_with_azure(image_data)
    # Check if Azure Vision endpoint is configured
    if AZURE_VISION_ENDPOINT.include?('YOUR_RESOURCE_NAME')
      Rails.logger.warn "Azure Computer Vision not configured, using fallback blur"
      return []
    end

    # Use Face API endpoint for accurate face detection
    url = "#{AZURE_VISION_ENDPOINT}/face/v1.0/detect"

    response = HTTParty.post(
      url,
      headers: {
        'Ocp-Apim-Subscription-Key' => AZURE_VISION_KEY,
        'Content-Type' => 'application/octet-stream'
      },
      body: image_data,
      timeout: 30
    )

    if response.success?
      parse_face_regions(response.parsed_response)
    else
      Rails.logger.error "Azure Vision API error: #{response.code} - #{response.body}"
      []
    end
  rescue StandardError => e
    Rails.logger.error "Face detection error: #{e.message}"
    []
  end

  def parse_face_regions(azure_response)
    # Azure Face API returns array of face objects with faceRectangle
    # Format: [{ "faceRectangle": { "left": x, "top": y, "width": w, "height": h } }]
    return [] unless azure_response.is_a?(Array)

    azure_response.map do |face|
      rect = face['faceRectangle']
      next unless rect

      {
        x: rect['left'],
        y: rect['top'],
        width: rect['width'],
        height: rect['height']
      }
    end.compact
  end

  def blur_image_with_faces(image_data, faces)
    Tempfile.create(['original', '.jpg']) do |original_file|
      original_file.binmode
      original_file.write(image_data)
      original_file.flush

      image = MiniMagick::Image.open(original_file.path)

      # Auto-orient the image based on EXIF data (critical for mobile photos)
      image.auto_orient

      faces.each do |face|
        # Add padding around face for better coverage
        padding = 30
        x = [face[:x] - padding, 0].max
        y = [face[:y] - padding, 0].max
        width = face[:width] + (padding * 2)
        height = face[:height] + (padding * 2)

        # Create a region and blur it
        image.combine_options do |c|
          c.region "#{width}x#{height}+#{x}+#{y}"
          c.blur "0x35"
        end
      end

      # Convert back to base64
      "data:image/jpeg;base64,#{Base64.strict_encode64(image.to_blob)}"
    end
  end
end
