class AddCrmObjectIdToContact < ActiveRecord::Migration
  def change
    add_column :contacts, :crm_object_id, :integer
  end
end
