class RemoveCounterTypeIdFromReadings < ActiveRecord::Migration
  def change
    remove_column :readings, :counter_type_id
  end
end
