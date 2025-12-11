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
      chat = Chat.create(ping: @ping)

      if @ping.photo.present?
        process_photo_with_blur(@ping)
      end
      process_location_with_llm(@ping, chat)

      NotifyNearbyUsersJob.perform_later(@ping.id)

      redirect_to ping_path(@ping), notice: "Ping created successfully! Analysis in progress..."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @ping = Ping.find(params[:id])

    if @ping.update(ping_params)
      if params[:ping][:photo].present?
        chat = @ping.chat || Chat.create(ping: @ping)
        process_photo_with_blur(@ping)
        process_location_with_llm(@ping, chat)
      end

      redirect_to ping_path(@ping), notice: "Photo uploaded and analysis started!"
    else
      render :show
    end
  end

  def share
    @ping = Ping.find(params[:id])

    @ping.update(shared_at: Time.current)

    # Award points to user
    reward_data = current_user.add_share_points!

    redirect_to ping_path(@ping,
      points_earned: reward_data[:points_earned],
      new_score: reward_data[:new_score],
      new_level: reward_data[:new_level],
      leveled_up: reward_data[:leveled_up]
    )
  end

  private

  def ping_params
    params.require(:ping).permit(:date, :heure, :comment, :photo, :latitude, :longitude, :nombre_personnes, :signe_distinctif)
  end

  def process_photo_with_blur(ping)
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

    llm_chat.with_instructions("You are a safety analyst that returns only JSON responses.")
    response = llm_chat.ask(prompt)

    danger_sites = response.content

    if danger_sites
      danger_sites = danger_sites.gsub(/```json\n?/, '').gsub(/```\n?/, '').strip

      begin
        JSON.parse(danger_sites)
        chat.update(danger_sites_json: danger_sites)
      rescue JSON::ParserError => e
        Rails.logger.error "Invalid JSON response: #{danger_sites}"
        chat.update(danger_sites_json: "[{\"error\": \"Could not parse AI response\"}]")
      end
    end
  rescue => e
    Rails.logger.error "Error processing location: #{e.message}"
    chat.update(danger_sites_json: "[{\"error\": \"#{e.message}\"}]")
  end
end
