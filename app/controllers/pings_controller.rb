class PingsController < ApplicationController
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
      if @ping.photo.present?
        create_chat_and_process(@ping)
      end

      redirect_to ping_path(@ping), notice: "Ping created successfully! Analysis in progress..."
    else
      render :new
    end
  end

  def update
    @ping = Ping.find(params[:id])

    if @ping.update(ping_params)
      if params[:ping][:photo].present? && @ping.chat.nil?
        create_chat_and_process(@ping)
      end

      redirect_to ping_path(@ping), notice: "Photo uploaded and analysis started!"
    else
      render :show
    end
  end

  private

  def ping_params
    params.require(:ping).permit(:date, :heure, :comment, :photo, :latitude, :longitude)
  end

  def create_chat_and_process(ping)
    chat = Chat.create(ping: ping)

    if ping.photo.present?
      process_photo_with_llm(ping)
    end

    process_location_with_llm(ping, chat)
  end

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

    prompt = "À partir des coordonnées GPS suivantes :
Latitude : #{ping.latitude}
Longitude : #{ping.longitude}

Analyse les données géographiques disponibles et identifie les 5 sites potentiellement en danger dans un rayon de 500 mètres autour de ce point.

Les sites à risque peuvent inclure : monuments historiques, sites sensibles, lieux très fréquentés, établissements publics, établissements scolaires.

Pour chaque site, retourne :
- Nom ou type du site
- Distance exacte et temps de trajet à pied depuis le point de départ (en mètres)
- Type de risque associé (ex : vandalisme, vol, agression, etc.)
- Niveau de danger (faible, modéré, élevé)

Retourne les résultats sous forme de liste structurée en JSON."

    response = llm_chat.completion(
      messages: [
        { role: "system", content: prompt },
        { role: "user", content: "Analyze the dangerous sites near these coordinates." }
      ]
    )

    danger_sites = response.dig("choices", 0, "message", "content")
    chat.update(danger_sites_json: danger_sites)
  rescue => e
    Rails.logger.error "Error processing location: #{e.message}"
  end
end
