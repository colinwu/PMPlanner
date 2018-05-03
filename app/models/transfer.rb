class Transfer < ActiveRecord::Base
  
  belongs_to :from_team, :class_name => 'Team', :foreign_key => :from_team_id
  belongs_to :to_team, :class_name => 'Team', :foreign_key => :to_team_id
  belongs_to :device
  
  # TODO Need validator to ensure there is only one unaccepted transfer per device
end
