class CreatePartsForPms < ActiveRecord::Migration
  def self.up
    create_table :parts_for_pms do |t|
      t.integer :model_group_id
      t.integer :pm_code_id
      t.integer :choice
      t.integer :part_id
      t.float :quantity
      t.timestamps
    end
  end

  def self.down
    drop_table :parts_for_pms
  end
end
