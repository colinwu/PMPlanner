class ModelGroup < ActiveRecord::Base
  attr_accessible :name, :description, :color_flag
  
  has_many :models, :dependent => :destroy
  has_many :model_targets, :dependent => :destroy, :inverse_of => :model_group
  has_many :parts_for_pms, :dependent => :destroy
  
  validates :name, :color_flag, presence: true
  validates :name, uniqueness: true
  
end
