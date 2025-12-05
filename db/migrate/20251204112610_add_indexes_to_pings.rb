class AddIndexesToPings < ActiveRecord::Migration[7.1]
  def change
    add_index :pings, [:latitude, :longitude]
    add_index :pings, :created_at
    add_index :pings, :shared_at
  end
end
