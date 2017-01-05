class Reading < ActiveRecord::Base
  attr_accessible :taken_at, :notes, :device_id, :technician_id, :ptn1
  
  belongs_to :device
  belongs_to :technician
  has_many :counters, :dependent => :destroy
  has_attached_file :ptn1, styles: {}, path: ":rails_root/public/system/readings/ptn1s/:filename"

  validates_attachment_file_name :ptn1, matches: [/PTN1\.txt\z/]
  validates_associated :counters
  validates_associated :device
  validates_associated :technician
  validate :taken_at_is_date
  
  def counter_for(code)
    self.counters.joins(:pm_code).where(["pm_codes.name = ?", code]).first    
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
  
  # Parse uploaded 22-6 file
  def process_ptn1
    seen = {date: false, model: false, sn: false}
    codes = {'TOTAL OUT(BW):' => 'BWTOTAL', 'TOTAL OUT(COL):' => 'CTOTAL'}
    counter_column = {0 => 'COUNTER', 1 => 'TURN', 2 => 'DAY', 3 => 'LIFE', 4 => 'REMAIN'}
    section = Hash.new
#     counter = Hash.new
#     turn = Hash.new
#     day = Hash.new
#     life = Hash.new
#     remain = Hash.new
    
    byebug
    
    dev = self.device
    ptn1_dev = nil
    if dev.nil?
      return "#{params[:reading][:devie_id]} is not a valid device."
    end
    
    ptn1_file = self.ptn1.path
    ptn1_file =~ /_(\d{12,12})_PTN/
    file_date = $1
    f = File.open(ptn1_file)
    while (row = f.gets)
      unless (seen[:model])
        if (row =~ /MACHINE:\s+([A-Z0-9-]+)/)
          model = $1.gsub(/\W/,'')
          seen[:model] = true
        end
      end
      unless (seen[:sn])
        if (row =~ /S\/N: (\w+)/)
          sn = $1
          seen[:sn] = true
        end
      end
      if (seen[:model] and seen[:sn])
        # make sure the 22-6 file is for this device.
        if ptn1_dev.nil?
          ptn1_dev = Device.joins(:model).where(["models.nm = ? and serial_number = ?", model, sn]).first
          if ptn1_dev.nil?
            return "Device specified by 22-6 file not found: #{model}, #{sn}"
          elsif ptn1_dev.id != dev.id
            return "The 22-6 file #{self.ptn1_file_name} is not for this device."
          else
            t = Technician.find(self.technician_id)
            self.taken_at = Date.parse(file_date)
            self.notes = "Readings uploaded from #{self.ptn1_file_name} by #{t.friendly_name}."
            self.save
            # generate list of PM codes for this model
            dev.model.model_group.model_targets.each do |c|
              unless c.label.nil?
                codes[c.label] = c.maint_code
                section[c.maint_code] = c.section
              end
            end
          end
        else
          codes.each do |label,name|
            new_label = label.gsub(/[()]/,{'(' => '\(',')' => '\)'})
            unless (seen[name])
              if (section[name] == '22-13')
                if (row =~ /#{new_label}\s+([-0-9]+)\s+([-0-9]+)\s+([-0-9]+)\s+([-0-9%]+)\s+([-0-9]+)/)
                  counter = $1.to_i
                  turn = $2.to_i
                  day = $3.to_i
                  life = $4.to_i
                  remain = $5.to_i
                  seen[name] = true
                end
              else
                if (row =~ /#{new_label}\s+(\d+)/)
                  counter = $1.to_i
                  seen[name] = true
                end #if
              end # else
              pm = PmCode.find_by_name name
              self.counters.create(pm_code_id: pm.id, value: counter, unit: 'counter')
            end # unless (seen[name])
          end # codes.each
        end
      end
    end
    return "22-6 file processed."
  end
end
