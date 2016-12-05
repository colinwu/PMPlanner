class CreateDevices < ActiveRecord::Migration
  def self.up
    create_table :devices do |t|
      t.string :installed_base_id
      t.string :crm_object_id
      t.string :alternate_id
      t.integer :model_id
      t.integer :client_id
      t.string :serial_number
      t.integer :location_id
      t.integer :primary_tech_id
      t.integer :backup_tech_id
      t.boolean :status
      t.boolean :under_contract
      t.boolean :do_pm
      t.integer :pm_counter_type_id
      t.float :pm_visits_min
      t.text :notes
      t.timestamps
    end
  end

  def self.down
    drop_table :devices
  end
end
