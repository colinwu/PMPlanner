class ReadingTarget < ActiveRecord::Base
  attr_accessible :target, :model_group_id, :counter_id
  
  belongs_to :model_group, :inverse_of => :reading_targets
  belongs_to :counter, :inverse_of => :reading_target
end
