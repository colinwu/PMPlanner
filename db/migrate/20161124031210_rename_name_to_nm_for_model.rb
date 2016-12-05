class RenameNameToNmForModel < ActiveRecord::Migration
  def change
    rename_column :models, :name, :nm
  end
end
