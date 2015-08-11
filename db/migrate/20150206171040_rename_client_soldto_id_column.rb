class RenameClientSoldtoIdColumn < ActiveRecord::Migration
  def change
    rename_column :clients, :soldto_id, :soldtoid
  end
end
