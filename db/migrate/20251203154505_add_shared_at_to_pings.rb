class AddSharedAtToPings < ActiveRecord::Migration[7.1]
  def change
    add_column :pings, :shared_at, :datetime
  end
end
