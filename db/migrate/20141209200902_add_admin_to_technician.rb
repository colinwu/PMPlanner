class AddAdminToTechnician < ActiveRecord::Migration
  def change
    add_column :technicians, :admin, :boolean, :default => false, :null => false
  end
end
