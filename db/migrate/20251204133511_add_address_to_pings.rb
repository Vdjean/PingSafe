class AddAddressToPings < ActiveRecord::Migration[7.1]
  def change
    add_column :pings, :address, :string
  end
end
