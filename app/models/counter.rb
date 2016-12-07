class Counter < ActiveRecord::Base
  attr_accessible :name, :reading_id, :pm_code_id, :value, :unit
  
  belongs_to :reading
  belongs_to :pm_code
  
  validates :value, numericality: true
end
