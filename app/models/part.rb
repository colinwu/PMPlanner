class Part < ApplicationRecord
  # This is complete list of parts available for servicing all devices
  
  has_many :parts_for_pms, :dependent => :destroy
  
  validates :name, presence: true
  validates :name, uniqueness: true

end
