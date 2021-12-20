class Reading < ApplicationRecord
  
  belongs_to :device
  belongs_to :technician
  has_many :counters, :dependent => :destroy
  # has_attached_file :ptn1, styles: {}, path: ":rails_root/public/system/readings/ptn1s/:filename"

  # validates_attachment_file_name :ptn1, matches: [/PTN1\.txt\z/]
  # validates_associated :counters
  validates_associated :device
  validates_associated :technician
  validate :taken_at_is_date
  # validates :taken_at, uniqueness: true
  
  def counter_for(code)
    c = self.counters.joins(:pm_code).where(["pm_codes.name = ?", code]).first
    if c.nil?
      pm_code_id = PmCode.find_by(name: code).id
      return Counter.new(pm_code_id: pm_code_id, value: 0, reading_id: self.id)
    else
      return c
    end
  end
  
  def taken_at_is_date
    unless taken_at.nil?
      begin
        status = Date.parse(taken_at.to_s)
      rescue
        errors.add(:taken_at, "#{taken_at} is not a valid date")
      end
    else
      return true
    end
  end
end