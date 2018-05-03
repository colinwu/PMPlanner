class Counter < ApplicationRecord
  
  belongs_to :reading
  belongs_to :pm_code
  
  validates :value, numericality: true
  validates :value, presence: true
end
