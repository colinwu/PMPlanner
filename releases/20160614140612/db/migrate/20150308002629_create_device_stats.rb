class CreateDeviceStats < ActiveRecord::Migration
  def change
    create_table :device_stats do |t|
      t.float :c_monthly
      t.float :bw_monthly
      t.float :vpy, :default => 2.0
      t.integer :device_id

      t.timestamps null: false
    end
  end
end
