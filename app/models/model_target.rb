class ModelTarget < ActiveRecord::Base
  attr_accessible :maint_code, :target, :model_group_id, :unit, :section, :label
  
  belongs_to :model_group
end
