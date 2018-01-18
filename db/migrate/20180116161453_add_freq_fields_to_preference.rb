class AddFreqFieldsToPreference < ActiveRecord::Migration
  def change
    add_column :preferences, :pm_list_freq, :integer, :default => 0
    add_column :preferences, :pm_list_freq_unit, :integer
  end
end
