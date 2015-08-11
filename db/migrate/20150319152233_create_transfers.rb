class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.integer :from_team_id
      t.integer :to_team_id
      t.integer :device_id
      t.boolean :accepted, default: false

      t.timestamps null: false
    end
  end
end
