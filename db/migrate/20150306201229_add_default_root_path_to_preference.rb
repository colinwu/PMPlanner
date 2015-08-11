class AddDefaultRootPathToPreference < ActiveRecord::Migration
  def change
    add_column :preferences, :default_root_path, :string, :default => '/devices/my_pm_list'
  end
end
