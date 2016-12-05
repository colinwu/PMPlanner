class PartsForPm < ActiveRecord::Base
# This model describes what part(s) are required to service a maintenence code (pm_code)
# for a model group. Each part may be used for more than one pm_code and for more than one
# model_group. Conversely, more 
# than one of the same part may be required to service a pm_code.
  
  attr_accessible :model_group_id, :pm_code_id, :choice, :part_id, :quantity
  
  belongs_to :model_group
  belongs_to :pm_code
  belongs_to :part
  
  validates_associated :model_group
  validates_associated :pm_code
  validates_associated :part
end
