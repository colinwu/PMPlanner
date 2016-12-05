class RenameLastVisitColumn < ActiveRecord::Migration
  def change
    rename_column :neglecteds, :last_visit, :next_visit
  end
end
