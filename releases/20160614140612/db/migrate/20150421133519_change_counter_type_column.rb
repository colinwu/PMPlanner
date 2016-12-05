class ChangeCounterTypeColumn < ActiveRecord::Migration
  def change
    rename_column :devices, :pm_counter_type_id, :pm_counter_type
    change_column :devices, :pm_counter_type, :string, :default => 'count'
  end
end
