class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams, :primary_key => :team_id, id: false do |t|
      t.integer :team_id
      t.string :name
      t.timestamps
    end
  end

  def self.down
    drop_table :teams
  end
end
