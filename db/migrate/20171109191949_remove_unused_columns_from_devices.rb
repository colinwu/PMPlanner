class RemoveUnusedColumnsFromDevices < ActiveRecord::Migration
  def change
    remove_column :devices, :installed_base_id, :string
    remove_column :devices, :alternate_id, :string
  end
end
