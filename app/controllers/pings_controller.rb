class PingsController < ApplicationController
  before_action :authenticate_user!

  def index
    @pings = current_user.pings
  end

  def show
    @ping = Ping.find(params[:id])
    @chat = @ping.chat
  end

  def new
    @ping = Ping.new
  end

  def create
    @ping = Ping.new(ping_params)
    @ping.user = current_user

    if @ping.save
      # Create chat immediately
      Chat.create(ping: @ping)

      # Process in background job (replaces Thread.new)
      ProcessPingJob.perform_later(@ping.id)

      redirect_to ping_path(@ping), notice: "Ping created successfully! Analysis in progress..."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @ping = Ping.find(params[:id])

    if @ping.update(ping_params)
      if params[:ping][:photo].present? && @ping.chat.nil?
        ProcessPingJob.perform_later(@ping.id)
      end

      redirect_to ping_path(@ping), notice: "Photo uploaded and analysis started!"
    else
      render :show
    end
  end

  def share
    @ping = Ping.find(params[:id])

    @ping.update(shared_at: Time.current)

    redirect_to ping_path(@ping), notice: "Ping shared with the Pinger community within 300 meters!"
  end

  private

  def ping_params
    params.require(:ping).permit(:date, :heure, :comment, :photo, :latitude, :longitude, :nombre_personnes, :signe_distinctif)
  end

  def create_chat_and_process(ping)
    chat = Chat.create(ping: ping)

    if ping.photo.present?
      process_photo_with_llm(ping)
    end

    process_location_with_llm(ping, chat)
  end

  def process_photo_with_llm(ping)
    # Use BlurredPhotoGeneratorService to detect faces and blur them
    blurred_image = BlurredPhotoGeneratorService.blur_faces(ping.photo)
    ping.update(blurred_photo_url: blurred_image)
    Rails.logger.info "Successfully blurred faces in photo for ping #{ping.id}"
  rescue => e
    Rails.logger.error "Error processing photo: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    # Store original photo as fallback
    ping.update(blurred_photo_url: ping.photo)
  end

  def process_location_with_llm(ping, chat)
    llm_chat = RubyLLM.chat

    prompt = "You are a location safety analyst. Based on the GPS coordinates provided (Latitude: #{ping.latitude}, Longitude: #{ping.longitude}), analyze and identify 5 potentially dangerous or at-risk sites within a 500-meter radius.

Consider these types of locations:
- Historical monuments
- Sensitive sites
- Highly frequented areas
- Public establishments
- Schools and educational facilities
- Dark alleys or isolated areas
- Areas with known crime statistics

For each site, provide:
1. Name or type of the site
2. Exact distance in meters from the starting point
3. Walking time to reach it
4. Type of associated risk (e.g., vandalism, theft, assault, etc.)
5. Danger level: low, moderate, or high

Return ONLY a valid JSON array with this structure:
[
  {
    \"name\": \"Site name\",
    \"distance_meters\": 250,
    \"walking_time\": \"3 minutes\",
    \"risk_type\": \"theft\",
    \"danger_level\": \"moderate\"
  }
]

Return ONLY the JSON array, no additional text."

    response = llm_chat.completion(
      messages: [
        { role: "system", content: "You are a safety analyst that returns only JSON responses." },
        { role: "user", content: prompt }
      ]
    )

    danger_sites = response.dig("choices", 0, "message", "content")

    # Clean up the response to ensure it's valid JSON
    if danger_sites
      # Remove markdown code blocks if present
      danger_sites = danger_sites.gsub(/```json\n?/, '').gsub(/```\n?/, '').strip

      # Validate JSON
      begin
        JSON.parse(danger_sites)
        chat.update(danger_sites_json: danger_sites)
        Rails.logger.info "Successfully saved danger sites analysis"
      rescue JSON::ParserError => e
        Rails.logger.error "Invalid JSON response: #{danger_sites}"
        Rails.logger.error "JSON Parse Error: #{e.message}"
        chat.update(danger_sites_json: "[{\"error\": \"Could not parse AI response\"}]")
      end
    end
  rescue => e
    Rails.logger.error "Error processing location: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    chat.update(danger_sites_json: "[{\"error\": \"#{e.message}\"}]")
  end
end
