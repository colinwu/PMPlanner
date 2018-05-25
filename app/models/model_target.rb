class ModelTarget < ApplicationRecord
  
  belongs_to :model_group
  before_destroy :cleanup_outstanding_pms

  def cleanup_outstanding_pms
    self.model_group.models.includes(:devices).each do |m|
      m.devices.includes(:outstanding_pms).each do |d|
        x = d.outstanding_pms.find_by(code: self.maint_code)
        unless x.nil?
          x.destroy
        end
      end
    end
  end
end
