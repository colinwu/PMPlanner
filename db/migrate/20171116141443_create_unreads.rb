class CreateUnreads < ActiveRecord::Migration
  def change
    create_table :unreads do |t|
      t.belongs_to :technician, index: true, foreign_key: true
      t.belongs_to :news, index: true, foreign_key: true
    end
  end
end
