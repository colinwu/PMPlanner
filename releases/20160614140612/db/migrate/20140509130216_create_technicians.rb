class CreateTechnicians < ActiveRecord::Migration
  def self.up
    create_table :technicians do |t|
      t.integer :team_id
      t.string :first_name
      t.string :last_name
      t.string :friendly_name
      t.string :sharp_name
      t.integer :car_stock_number
      t.string :email
      t.string :crm_id
      t.timestamps
    end
  end

  def self.down
    drop_table :technicians
  end
end
