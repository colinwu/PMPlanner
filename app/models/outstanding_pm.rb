class OutstandingPm < ActiveRecord::Base
  attr_accessible :device_id, :code, :next_pm_date
  belongs_to :device
end
