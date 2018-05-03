class Neglected < ApplicationRecord
  # attr_accessible :device_id, :next_visit
  belongs_to :device, inverse_of: :neglected
end
