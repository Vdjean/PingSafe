class RemoveDetailsFromPings < ActiveRecord::Migration[7.1]
  def change
    remove_column :pings, :nb_individus, :integer
    remove_column :pings, :taille, :string
    remove_column :pings, :signe_distinctif, :string
  end
end
