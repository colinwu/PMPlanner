class CreateContacts < ActiveRecord::Migration
  def self.up
    create_table :contacts do |t|
      t.string :name
      t.string :phone1
      t.string :phone2
      t.string :email
      t.string :notes
      t.integer :client_id
      t.timestamps
    end
  end

  def self.down
    drop_table :contacts
  end
end
