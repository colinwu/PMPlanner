class CreateTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :transfers do |t|
      t.string :tx_file_name
      t.string :tx_type
      t.integer :tx_file_size
      t.datetime :tx_update_at

      t.timestamps
    end
  end
end
