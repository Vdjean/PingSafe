class CreateUserRewards < ActiveRecord::Migration[7.1]
  def change
    create_table :user_rewards do |t|
      t.references :rewards, null: false, foreign_key: true
      t.references :users, null: false, foreign_key: true

      t.timestamps
    end
  end
end
