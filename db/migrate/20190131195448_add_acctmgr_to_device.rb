class AddAcctmgrToDevice < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :acctmgr, :string
  end
end
