class CreateClients < ActiveRecord::Migration
  def self.up
    create_table :clients do |t|
      t.string :name
      t.string :address
      t.string :city
      t.string :province
      t.string :postal_code
      t.text :notes
      t.timestamps
    end
  end

  def self.down
    drop_table :clients
  end
end
