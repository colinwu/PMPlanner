class AddTeamIdToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :team_id, :integer
  end
end
