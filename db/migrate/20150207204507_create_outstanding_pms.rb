class CreateOutstandingPms < ActiveRecord::Migration
  def change
    create_table :outstanding_pms do |t|
      t.integer :device_id
      t.string :code
      t.date :next_pm_date

      t.timestamps null: false
    end
  end
end
