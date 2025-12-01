class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :pseudo
      t.string :password
      t.string :phone
      t.integer :score

      t.timestamps
    end
  end
end
