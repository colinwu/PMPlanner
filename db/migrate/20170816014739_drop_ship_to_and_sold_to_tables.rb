class DropShipToAndSoldToTables < ActiveRecord::Migration
  def change
    drop_table :ship_tos
    drop_table :sold_tos
  end
end
