class Model < ActiveRecord::Base
  attr_accessible :nm, :model_group_id
  
  belongs_to :model_group
  has_many :devices, :dependent => :destroy
  
  validates :nm, presence: true
  validates :nm, uniqueness: true
  
end
