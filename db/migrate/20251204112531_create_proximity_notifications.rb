class CreateProximityNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :proximity_notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :ping, null: false, foreign_key: true
      t.datetime :notified_at, null: false

      t.timestamps
    end

    add_index :proximity_notifications, [:user_id, :ping_id], unique: true
  end
end
