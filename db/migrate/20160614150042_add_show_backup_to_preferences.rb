class AddShowBackupToPreferences < ActiveRecord::Migration
  def change
    add_column :preferences, :showbackup, :boolean
  end
end
