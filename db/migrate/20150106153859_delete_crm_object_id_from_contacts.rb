class DeleteCrmObjectIdFromContacts < ActiveRecord::Migration
  def change
    remove_column :contacts, :crm_object_id
  end
end
