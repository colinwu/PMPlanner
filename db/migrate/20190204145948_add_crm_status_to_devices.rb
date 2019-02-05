class AddCrmStatusToDevices < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :crm_active, :boolean
    add_column :devices, :crm_under_contract, :boolean
    add_column :devices, :crm_do_pm, :boolean
  end
end
