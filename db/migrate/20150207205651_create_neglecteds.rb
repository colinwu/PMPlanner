class CreateNeglecteds < ActiveRecord::Migration
  def change
    create_table :neglecteds do |t|
      t.integer :device_id
      t.date :last_visit

      t.timestamps null: false
    end
  end
end
