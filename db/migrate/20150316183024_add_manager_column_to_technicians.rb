class AddManagerColumnToTechnicians < ActiveRecord::Migration
  def change
    add_column :technicians, :manager, :boolean, :default => false
  end
end
