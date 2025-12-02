class CreateUserLevels < ActiveRecord::Migration[7.1]
  def change
    create_table :user_levels do |t|
      t.references :users, null: false, foreign_key: true
      t.references :levels, null: false, foreign_key: true
      t.string :level_name

      t.timestamps
    end
  end
end
