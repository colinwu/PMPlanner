class RemoveIndexOnTechEmail < ActiveRecord::Migration
  def change
    remove_index :technicians, name: "index_technicians_on_email"
  end
end
