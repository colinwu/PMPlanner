class RemoveUnusedFieldsFromTechnicians < ActiveRecord::Migration
  def change
    remove_column :technicians, :encrypted_password
    remove_column :technicians, :reset_password_token
    remove_column :technicians, :reset_password_sent_at
    remove_column :technicians, :remember_created_at
    remove_column :technicians, :sign_in_count
  end
end
