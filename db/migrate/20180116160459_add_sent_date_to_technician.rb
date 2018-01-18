class AddSentDateToTechnician < ActiveRecord::Migration
  def change
    add_column :technicians, :sent_date, :date
  end
end
