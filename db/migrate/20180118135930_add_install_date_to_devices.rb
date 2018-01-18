class AddInstallDateToDevices < ActiveRecord::Migration
  def change
    add_column :devices, :install_date, :date
  end
end
