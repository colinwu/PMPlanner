class RenameDeviceStatusToActive < ActiveRecord::Migration
  def change
    rename_column :devices, :status, :active
  end
end
