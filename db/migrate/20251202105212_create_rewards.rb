class CreateRewards < ActiveRecord::Migration[7.1]
  def change
    create_table :rewards do |t|
      t.string :reward_type

      t.timestamps
    end
  end
end
