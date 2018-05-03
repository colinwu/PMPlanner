class Model < ApplicationRecord
  
  belongs_to :model_group
  has_many :devices, :dependent => :destroy
  
  validates :nm, presence: true
  validates :nm, uniqueness: true
end
