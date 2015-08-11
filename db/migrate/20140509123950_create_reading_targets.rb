class CreateReadingTargets < ActiveRecord::Migration
  def self.up
    create_table :reading_targets do |t|
      t.integer :target
      t.integer :model_group_id
      t.integer :counter_id
      t.integer :counter_type_id
      t.timestamps
    end
  end

  def self.down
    drop_table :reading_targets
  end
end
