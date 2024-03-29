class Team < ApplicationRecord
  
  has_many :technicians, :dependent => :nullify, :foreign_key => 'team_id'
  has_many :devices, :foreign_key => 'team_id'
  has_many :locations, :foreign_key => 'team_id'
  has_many :from_transfers, :class_name => 'Transfer', :foreign_key => 'from_team_id', :dependent => :destroy
  has_many :to_transfers, :class_name => 'Transfer', :foreign_key => 'to_team_id', :dependent => :destroy
  belongs_to :manager, :class_name => 'Technician', :foreign_key => 'manager_id'
  
  validates :name, :team_id, uniqueness: true
end
