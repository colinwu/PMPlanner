class Log < ActiveRecord::Base
  attr_accessible :technician_id, :device_id, :message
  
  belongs_to :technician
  belongs_to :device
  
  validates :technician_id, :message, presence: true
  validates :technician_id, numericality: { greater_than: 0 }
end
