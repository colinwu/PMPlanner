class Log < ApplicationRecord
  
  belongs_to :technician
  belongs_to :device
  
  validates :message, presence: true
  validates :technician_id, numericality: { greater_than: 0 }, allow_nil: true
end
