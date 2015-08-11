class Neglected < ActiveRecord::Base
  attr_accessible :device_id, :next_visit
  belongs_to :device
end
