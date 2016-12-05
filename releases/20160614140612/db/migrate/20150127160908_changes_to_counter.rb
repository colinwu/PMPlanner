class ChangesToCounter < ActiveRecord::Migration
  def self.up
    change_table :counters do |t|
      t.remove :description
      t.remove :maint_code
      t.integer :reading_id
      t.integer :pm_code_id
      t.integer :value
      t.string :unit
    end
  end
  
  def self.down
    change_table :counters do |t|
      t.string :description
      t.string :maint_code
      t.remove :reading_id
      t.remove :pm_code_id
      t.remove :value
      t.remove :unit
    end
  end
end
