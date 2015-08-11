class CreateModelTargets < ActiveRecord::Migration
  def self.up
    create_table :model_targets do |t|
      t.string :maint_code
      t.integer :target
      t.integer :model_group_id
      t.string :unit
      t.timestamps
    end
  end

  def self.down
    drop_table :model_targets
  end
end
