class CreateNews < ActiveRecord::Migration
  def change
    create_table :news do |t|
      t.text :note
      t.date :activate
      t.boolean :urgent

      t.timestamps null: false
    end
  end
end
