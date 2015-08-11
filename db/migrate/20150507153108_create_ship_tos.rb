class CreateShipTos < ActiveRecord::Migration
  def change
    create_table :ship_tos do |t|
      t.integer :ship_to_id
      t.integer :location_id
      t.integer :client_id

      t.timestamps null: false
    end
  end
end
