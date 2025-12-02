class CreatePings < ActiveRecord::Migration[7.1]
  def change
    create_table :pings do |t|
      t.date :date
      t.time :heure
      t.text :comment
      t.string :photo
      t.decimal :latitude
      t.decimal :longitude
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
