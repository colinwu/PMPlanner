class AddLocationAndCrmToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :location_id, :integer
    add_column :contacts, :crm_object_id, :integer
  end
end
