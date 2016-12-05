class Model < ActiveRecord::Base
  attr_accessible :name, :model_group_id
  
  belongs_to :model_group
  has_many :devices, :dependent => :destroy
  
  validates :name, presence: true
  validates :name, uniqueness: true
end
