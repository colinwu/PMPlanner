class AddManagerIdToTeam < ActiveRecord::Migration
  def change
    add_column :teams, :manager_id, :integer
  end
end
