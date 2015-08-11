class RemoveZoomColumnsFromPrefs < ActiveRecord::Migration
  def change
    remove_column :preferences, :zoom
    remove_column :preferences, :zoom_level
    remove_column :preferences, :zoom_start
  end
end
