class CreatePushSubscriptions < ActiveRecord::Migration[7.1]
  def change
    create_table :push_subscriptions do |t|
      t.references :user, null: false, foreign_key: true
      t.string :endpoint, null: false
      t.string :p256dh_key, null: false
      t.string :auth_key, null: false
      t.decimal :last_latitude, precision: 10, scale: 6
      t.decimal :last_longitude, precision: 10, scale: 6
      t.datetime :last_location_at

      t.timestamps
    end

    add_index :push_subscriptions, :endpoint, unique: true
  end
end
