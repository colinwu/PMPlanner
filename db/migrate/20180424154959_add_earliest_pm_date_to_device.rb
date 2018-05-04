class AddEarliestPmDateToDevice < ActiveRecord::Migration[5.2]
  def change
    add_column :devices, :earliest_pm_date, :date
  end
end
