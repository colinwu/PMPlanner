class CreateModels < ActiveRecord::Migration
  def self.up
    create_table :models do |t|
      t.string :name
      t.integer :model_group_id
      t.timestamps
    end
  end

  def self.down
    drop_table :models
  end
end
