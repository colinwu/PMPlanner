class AddDailyToDeviceStat < ActiveRecord::Migration
  def change
    add_column :device_stats, :bw_daily, :float
    add_column :device_stats, :c_daily, :float
  end
end
