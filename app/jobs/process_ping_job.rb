class ProcessPingJob < ApplicationJob
  queue_as :default

  def perform(ping_id)
    ping = Ping.find_by(id: ping_id)
    return unless ping

    chat = ping.chat || Chat.create(ping: ping)

    process_photo_with_llm(ping) if ping.photo.present?
    process_location_with_llm(ping, chat)
  end

  private

  def process_photo_with_llm(ping)
    llm_chat = RubyLLM.chat

    prompt = "Floute dans l'image seulement les visages en conservant les couleurs et les formes générales.
Applique un flou gaussien homogène sans recadrage, sans ajout d'éléments et sans modification des contrastes.
Résultat attendu : image avec visages floutés et le reste sans aucune modification."

    response = llm_chat.completion(
      messages: [
        { role: "system", content: prompt },
        { role: "user", content: "Process this photo: #{ping.photo}" }
      ]
    )

    blurred_url = response.dig("choices", 0, "message", "content")
    ping.update(blurred_photo_url: blurred_url)
  rescue => e
    Rails.logger.error "Error processing photo: #{e.message}"
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
