class AddDailyToDeviceStat < ActiveRecord::Migration[4.2]
  def change
    add_column :device_stats, :bw_daily, :float
    add_column :device_stats, :c_daily, :float
  end
end
