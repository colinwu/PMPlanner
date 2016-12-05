class AddSoldtoIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :soldto_id, :integer
  end
end
