class AddDetailsToPings < ActiveRecord::Migration[7.1]
  def change
    add_column :pings, :nb_individus, :integer
    add_column :pings, :taille, :string
    add_column :pings, :signe_distinctif, :string
  end
end
