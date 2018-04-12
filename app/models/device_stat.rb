class DeviceStat < ActiveRecord::Base
  attr_accessible :c_monthly, :bw_monthly, :vpy, :device_id, :bw_daily, :c_daily
  
  belongs_to :device, inverse_of: :device_stat
  
  validates :c_monthly, :bw_monthly, :vpy, presence: true
  validates :c_monthly, :bw_monthly, :vpy, numericality: { greater_than_or_equal_to: 0 }
end
