class CreatePmCodes < ActiveRecord::Migration
  def self.up
    create_table :pm_codes do |t|
      t.string :name
      t.string :description
      t.string :colorclass
      t.timestamps
    end
  end

  def self.down
    drop_table :pm_codes
  end
end
