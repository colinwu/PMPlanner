class Reading < ActiveRecord::Base
  attr_accessible :taken_at, :notes, :device_id, :technician_id
  
  belongs_to :device
  belongs_to :technician
  has_many :counters, :dependent => :destroy

#   validates_associated :counters
#   validates_associated :device
#   validates_associated :technician
#   validate :taken_at_is_date
  
  def counter_for(code)
    self.counters.joins(:pm_code).where(["pm_codes.name = ?", code]).first    
  end
  
  def taken_at_is_date
    begin
      status = Date.parse(self.taken_at)
    rescue
      errors.add(:taken_at, "is not a valid date")
    end
  end
end
