class ChatsController < ApplicationController
  SYSTEM_PROMPT_PICTURE = "Floute dans l'image seulement les visages en conservant les couleurs et les formes générales.
Applique un flou gaussien homogène sans recadrage, sans ajout d'éléments et sans modification des contrastes.
Résultat attendu : image avec visages floutés et le reste sans aucune modification."

  SYSTEM_PROMPT_LOCALISATION = "À partir des coordonnées GPS suivantes :
Latitude : [LATITUDE]
Longitude : [LONGITUDE]

Analyse les données géographiques disponibles et identifie les 5 sites potentiellement en danger dans un rayon de 500 mètres autour de ce point.

Les sites à risque peuvent inclure : monuments historiques, sites sensibles, lieux très fréquentés, établissements publics, établissements scolaires.

Pour chaque site, retourne :
- Nom ou type du site
- Distance exacte et temps de trajet à pied depuis le point de départ (en mètres)
- Type de risque associé (ex : vandalisme, vol, agression, etc.)
- Niveau de danger (faible, modéré, élevé)

Retourne les résultats sous forme de liste structurée en JSON."

  def create
    @ping = Ping.find(params[:ping_id])

    # Create chat
    @chat = Chat.new
    @chat.ping = @ping

    if @chat.save
      # Process photo with LLM if photo exists
      if @ping.photo.present?
        process_photo_with_llm(@ping)
      end

      # Process location with LLM
      process_location_with_llm(@ping, @chat)

      redirect_to ping_path(@ping), notice: "Analysis completed successfully!"
    else
      redirect_to ping_path(@ping), alert: "Failed to create chat."
    end
  end

  private

  def process_photo_with_llm(ping)
    # Use BlurredPhotoGeneratorService to detect faces and blur them
    blurred_image = BlurredPhotoGeneratorService.blur_faces(ping.photo)
    ping.update(blurred_photo_url: blurred_image)
    Rails.logger.info "Successfully blurred faces in photo for ping #{ping.id}"
  rescue => e
    Rails.logger.error "Error processing photo: #{e.message}"
    # Store original photo as fallback
    ping.update(blurred_photo_url: ping.photo)
  end

  def process_location_with_llm(ping, chat)
    llm_chat = RubyLLM.chat

    # Replace coordinates in the prompt
    location_prompt = SYSTEM_PROMPT_LOCALISATION
      .gsub("[LATITUDE]", ping.latitude.to_s)
      .gsub("[LONGITUDE]", ping.longitude.to_s)

    # Call LLM to analyze dangerous sites
    response = llm_chat.completion(
      messages: [
        { role: "system", content: location_prompt },
        { role: "user", content: "Analyze the dangerous sites near these coordinates." }
      ]
    )

    # Store the danger sites JSON
    danger_sites = response.dig("choices", 0, "message", "content")
    chat.update(danger_sites_json: danger_sites)
  rescue => e
    Rails.logger.error "Error processing location: #{e.message}"
  end
end
