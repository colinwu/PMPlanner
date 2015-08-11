class ShipTo < ActiveRecord::Base
  attr_accessible :ship_to_id, :client_id, :location_id
end
