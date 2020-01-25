class Log < ApplicationRecord
  
  belongs_to :technician, optional: true
  belongs_to :device, optional: true
  
  validates :message, presence: true
  validates :technician_id, numericality: { greater_than: 0 }, allow_nil: true

  def to_csv
    '"' + [self.created_at.to_formatted_s(:rfc822), self.technician.nil? ? '' : self.technician.friendly_name, self.device.nil? ? '' : self.device.crm_object_id, self.message].join('","') + '"'
  end
end
