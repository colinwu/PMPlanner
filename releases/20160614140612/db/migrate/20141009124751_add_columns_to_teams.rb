class AddColumnsToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :crm_name, :string
    add_column :teams, :warehouse_id, :string
  end
end
