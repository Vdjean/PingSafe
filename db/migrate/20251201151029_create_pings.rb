class CreatePings < ActiveRecord::Migration[7.1]
  def change
    create_table :pings do |t|
      t.date :date
      t.time :time
      t.text :comment
      t.string :photo
      t.float :latitude
      t.float :longitude
      t.references :users, null: false, foreign_key: true

      t.timestamps
    end
  end
end
