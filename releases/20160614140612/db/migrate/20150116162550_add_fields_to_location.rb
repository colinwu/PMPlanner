class AddFieldsToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :shiptoid, :integer
    add_column :locations, :client_id, :integer
  end
end
