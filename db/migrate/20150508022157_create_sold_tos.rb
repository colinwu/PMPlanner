class CreateSoldTos < ActiveRecord::Migration
  def change
    create_table :sold_tos do |t|
      t.integer :sold_to_id
      t.integer :client_id

      t.timestamps null: false
    end
  end
end
