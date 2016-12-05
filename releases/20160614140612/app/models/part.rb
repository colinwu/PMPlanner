class Part < ActiveRecord::Base
  # This is complete list of parts available for servicing all devices
  
  attr_accessible :name, :description, :price, :new_name
  has_many :parts_for_pms, :dependent => :destroy
  
  validates :name, presence: true
  validates :name, uniqueness: true

end
