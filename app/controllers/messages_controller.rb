class MessagesController < ApplicationController
SYSTEM_PROMPT_PICTURE = "Floute dans l’image seulement les visages en conservant les couleurs et les formes générales.
Applique un flou gaussien homogène sans recadrage, sans ajout d’éléments et sans modification des contrastes.
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

  def initialize(ping)
    @ping = plan
    @llm_chat = RubyLLM.chat
  end

  def create
    @chat = Chat.find(params[:chat_id])
    @message = Message.new(message_params)
    @message.chat = @chat
    if @message.save
      redirect_to chat_path(@chat), notice: "Message sent."
    else
      redirect_to chat_path(@chat), alert: "Failed to send message."
    end
  end

  private
  def message_params
    params.require(:message).permit(:content)
  end
end
