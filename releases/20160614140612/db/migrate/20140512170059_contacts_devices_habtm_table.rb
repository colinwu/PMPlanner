class ContactsDevicesHabtmTable < ActiveRecord::Migration
  def self.up
    create_table :contacts_devices, :id => false do |t|
      t.integer :contact_id
      t.integer :device_id
    end
  end

  def self.down
    drop_table :contacts_devices
  end
end
