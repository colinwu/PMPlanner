class CreateLocations < ActiveRecord::Migration
  def self.up
    create_table :locations do |t|
      t.string :address1
      t.string :address2
      t.string :city
      t.string :province
      t.string :post_code
      t.string :notes
      t.timestamps
    end
  end

  def self.down
    drop_table :locations
  end
end
