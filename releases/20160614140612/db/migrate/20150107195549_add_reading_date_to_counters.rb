class AddReadingDateToCounters < ActiveRecord::Migration
  def change
    add_column :counters, :reading_date, :date
  end
end
