class AddTeamIdToDevice < ActiveRecord::Migration
  def change
    add_column :devices, :team_id, :integer
  end
end
