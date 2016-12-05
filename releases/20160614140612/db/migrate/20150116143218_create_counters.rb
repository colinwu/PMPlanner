class CreateCounters < ActiveRecord::Migration
  def self.up
    create_table :counters do |t|
      t.string :name
      t.string :description
      t.string :maint_code
      t.timestamps
    end
  end

  def self.down
    drop_table :counters
  end
end
