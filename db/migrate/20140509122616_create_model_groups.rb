class CreateModelGroups < ActiveRecord::Migration
  def self.up
    create_table :model_groups do |t|
      t.string :name
      t.string :description
      t.timestamps
    end
  end

  def self.down
    drop_table :model_groups
  end
end
