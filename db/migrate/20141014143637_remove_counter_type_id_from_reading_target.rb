class RemoveCounterTypeIdFromReadingTarget < ActiveRecord::Migration
  def up
    remove_column :reading_targets, :counter_type_id
  end

  def down
    add_column :reading_targets, :counter_type_id, :integer
  end
end
