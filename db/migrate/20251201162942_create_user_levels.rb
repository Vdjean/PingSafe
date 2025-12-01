class CreateUserLevels < ActiveRecord::Migration[7.1]
  def change
    create_table :user_levels do |t|
      t.references :user, null: false, foreign_key: true
      t.references :level, null: false, foreign_key: true
      t.string :level_name

      t.timestamps
    end
  end
end
