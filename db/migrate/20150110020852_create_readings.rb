class CreateReadings < ActiveRecord::Migration
  def self.up
    create_table :readings do |t|
      t.date :taken_at
      t.string :notes
      t.integer :device_id
      t.integer :technician_id
      t.timestamps
    end
  end

  def self.down
    drop_table :readings
  end
end
