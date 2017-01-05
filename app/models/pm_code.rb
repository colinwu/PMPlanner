class PmCode < ActiveRecord::Base
  attr_accessible :name, :description, :colorclass
  
#   has_and_belongs_to_many :parts_for_pms
  has_many :counters
  
  validates :name, presence: true
end
