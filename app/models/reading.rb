class Reading < ApplicationRecord
  
  belongs_to :device
  belongs_to :technician
  has_many :counters, :dependent => :destroy
  has_attached_file :ptn1, styles: {}, path: ":rails_root/public/system/readings/ptn1s/:filename"

  validates_attachment_file_name :ptn1, matches: [/PTN1\.txt\z/]
  # validates_associated :counters
  validates_associated :device
  validates_associated :technician
  validate :taken_at_is_date
#   validates :taken_at, uniqueness: true
  
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
  
  # Parse uploaded PTN1 file
  Sec = Struct.new(:line, :c_start, :len)
  def process_ptn1
    # seen = Hash.new(date: false, model: false, sn: false)
    seen = Hash.new
    line_number = 1
    content = Array.new
    idx = new_start = max_len = 0
    prev_section = ''
    ptn1_sec = Hash.new
    model = ''
    sn = ''
    codes = {}
    counter_column = {0 => 'COUNTER', 1 => 'TURN', 2 => 'DAY', 3 => 'LIFE', 4 => 'REMAIN'}
    section = {}
    dev = self.device
    ptn1_dev = nil
    if dev.nil?
      return "#{params[:reading][:devie_id]} is not a valid device."
    end

    ptn1_file = self.ptn1.path
    ptn1_file =~ /_(\d+)_PTN/
    file_date = $1.slice(0,8)
    f = File.open(ptn1_file)
    if f.nil?
      return "Could not open PTN1 file #{ptn1_file}."
    end
    # Read the contents of the file into the array 'content' and figure out the 
    # co-ordinates [line, start_column, length] of each SIM section. length is nil
    # means it is the last section horizontally; i.e. the section's data goes from
    # the start_column to the end of the line
    while (line = f.gets)
      content << line
      # find the model and serial numbers
      unless (seen[:model])
        if (line =~ /MACHINE:\s+([A-Z0-9-]+)/)
          model = $1.gsub(/\W/,'')
          seen[:model] = true
        end
      end
      unless (seen[:sn])
        if (line =~ /S\/N: (\w+)/)
          sn = $1.slice(0,8)
          seen[:sn] = true
        end
      end
      while (idx = line.index(/\(SIM(22-\d\d)/, new_start))
        sec_name = $1
        ptn1_sec[sec_name] = Sec.new(line_number, idx, 999)
        unless prev_section.length == 0
          ptn1_sec[prev_section].len = ptn1_sec[sec_name].c_start - ptn1_sec[prev_section].c_start
        end
        new_start = idx + 1
        prev_section = sec_name
      end
      idx = 0
      new_start = 0
      prev_section = ''
      line_number += 1
    end
    f.close
  
    if (seen[:model] and seen[:sn])
      # make sure the 22-6 file is for this device.
      # devs = Device.joins(:model).where(["models.nm = ? and (serial_number like ?)", model, "#{sn}%"])

      # if device is not the template, and model or sn not the same as those specified in the file
      if dev.id != 1 and (dev.model.nm != model or dev.serial_number.slice(0,8) != sn)
        return "Device specified by PTN1 file is not for this device (#{dev.model.nm} vs #{model}), (#{dev.serial_number.slice(0,8)} vs #{sn})."
      # elsif devs.length == 1
      elsif dev.id == 1 or (dev.model.nm == model and dev.serial.slice(0,8) == sn)
        ptn1_dev = Device.joins(:model).where("models.nm = '#{model}' and serial_number = '#{sn}'")
        if ptn1_dev.empty?
          return "The device for this PTN1 file is not in the database."
        end
        dev = ptn1_dev.first
        self.device_id = dev.id
        # if ptn1_dev.id != dev.id
        #   return "The file #{self.ptn1_file_name} is not for this device."
        # else
        t = Technician.find(self.technician_id)
        self.taken_at = Date.parse(file_date)
        self.notes = "Readings uploaded from #{self.ptn1_file_name} by #{t.friendly_name}."
        self.save
        # generate list of PM codes for this model
        dev.model.model_group.model_targets.each do |c|
          unless (c.label.nil? or c.label.strip.empty?)
            codes[c.label] = c.maint_code
            section[c.maint_code] = c.section
          end
        end
          # if it's a colour model add the CTOTAL code
          # if dev.model.model_group.color_flag
          #   codes['TOTAL OUT(COL):'] = 'CTOTAL'
          #   section['CTOTAL'] = '22-01'
          # end
        # end
        codes.each do |label,name|
          new_label = label.gsub(/[()]/,{'(' => '\(',')' => '\)'})
          if ptn1_sec[section[name]].nil?
            dev.logs.create(message: "Don't know what section (#{label}, #{name}) is in.")
            next
          end
          line_idx = ptn1_sec[section[name]].line
          start_column = ptn1_sec[section[name]].c_start
          column_width = ptn1_sec[section[name]].len.nil? ? max_len : ptn1_sec[section[name]].len
          if name == 'PPF'
            ppf_max = 0
            while (row = content[line_idx][start_column, column_width] and not row =~ /^$/ and not row =~ /\(SIM/)
              if row =~ /#{new_label}\s+(\d+)/
                ppf_max = (ppf_max < $1.to_i) ? $1.to_i : ppf_max
              end
              line_idx += 1
            end          
            counter = ppf_max
          else
            unit = 0
            begin
              row = content[line_idx][start_column, column_width]
              line_idx += 1
            end until (row =~ /#{new_label}\s*([-0-9]+)/ or row =~ /^$/ or row =~ /\(SIM/)
            counter = $1.to_i
            if (section[name] == '22-13')
              if (row =~ /#{new_label}\s*([-0-9]+)\s+([-0-9]+)\s+([-0-9]+)\s+([-0-9%]+)\s+([-0-9]+)/)
                count_ary = [$1, $2, $3, $4, $5]
                unit = count_ary[dev.pm_counter_type.to_i] == '--------' ? 0 : dev.pm_counter_type.to_i
                counter = count_ary[unit].to_i
              end
            end
          end
          pm = PmCode.find_by name: name
          self.counters.find_or_create_by(pm_code_id: pm.id, value: counter, unit: unit)
        end # codes.each
        return "PTN1 file processed."
      else
        return "Unanticipated problem occured. Please report this to your manager."
      end
    else
      return "Could not find model and/or serial number in the uploaded file."
    end
  end
end
