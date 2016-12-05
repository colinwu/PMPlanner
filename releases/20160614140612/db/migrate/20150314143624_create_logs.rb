class CreateLogs < ActiveRecord::Migration
  def change
    create_table :logs do |t|
      t.integer :technician_id
      t.integer :device_id
      t.text :message

      t.timestamps null: false
    end
  end
end
