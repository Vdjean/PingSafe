class AddLlmResultsToChatsAndPings < ActiveRecord::Migration[7.1]
  def change
    add_column :pings, :blurred_photo_url, :string
    add_column :chats, :danger_sites_json, :text
  end
end
