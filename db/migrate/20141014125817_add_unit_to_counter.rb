class AddUnitToCounter < ActiveRecord::Migration
  def change
    add_column :counters, :unit, :string
  end
end
