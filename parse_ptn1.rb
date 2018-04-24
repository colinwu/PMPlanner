def process_ptn1

  seen = {date: false, model: false, sn: false}
  Sec = Struct.new(:line, :c_start, :len)
  line_number = 1
  content = Array.new
  idx = new_start = max_len = 0
  prev_section = ''
  ptn1_sec = Hash.new
  model = sn = ''
  codes = {'TOTAL OUT(BW):' => 'BWTOTAL'}
  counter_column = {0 => 'COUNTER', 1 => 'TURN', 2 => 'DAY', 3 => 'LIFE', 4 => 'REMAIN'}
  section = {'BWTOTAL' => '22-01'}
  dev = self.device
  ptn1_dev = nil
  if dev.nil?
    return "#{params[:reading][:devie_id]} is not a valid device."
  end
  
  ptn1_file = self.ptn1.path
  ptn1_file =~ /_(\d+)_PTN/
  file_date = $1.slice(0,8)
  f = File.open(ptn1_file)
  
  # Read the contents of the file into the array 'content' and figure out the 
  # co-ordinates [line, start_column, length] of each SIM section. length is nil
  # means it is the last section horizontally; i.e. the section's data goes from
  # the start_column to the end of the line
  while (line = f.gets)
    content << line
    max_len = (max_len < line.length) ? line.length : max_len
    # find the model and serial numbers
    unless (seen[:model])
      if (row =~ /MACHINE:\s+([A-Z0-9-]+)/)
        model = $1.gsub(/\W/,'')
        seen[:model] = true
      end
    end
    unless (seen[:sn])
      if (row =~ /S\/N: (\w+)/)
        sn = $1.slice(0,8)
        seen[:sn] = true
      end
    end
    while (idx = line.index(/\(SIM(22-\d\d)/, new_start))
      sec_name = $1
      puts "Found #{sec_name} at line #{line_number}"
      section[sec_name] = Sec.new(line_number, idx, 999)
      unless prev_section.length == 0
        section[prev_section].len = section[sec_name].c_start - section[prev_section].c_start
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
      # if it's a colour model add the CTOTAL code
      if dev.model.model_group.color_flag
        codes['TOTAL OUT(COL):'] = 'CTOTAL'
        section['CTOTAL'] = '22-01'
      end
    end
    codes.each do |label,name|
      new_label = label.gsub(/[()]/,{'(' => '\(',')' => '\)'})
      line_idx = ptn1_sec[section[name]].line
      start_column = ptn1_sec[section[name]].c_start
      column_width = ptn1_sec[section[name]].len.nil? ? max_len : ptn1_sec[section[name]].len
      begin
        row = content[line_idx][start_column, column_width]
        line_idx += 1
      end until (row =~ /#{new_label}\s+([-0-9]+)/ or row =~ /^$/ or row =~ /\(SIM/)
      counter = $1.to_i
      if (section[name] == '22-13')
        if (row =~ /#{new_label}\s+([-0-9]+)\s+([-0-9]+)\s+([-0-9]+)\s+([-0-9%]+)\s+([-0-9]+)/)
          turn = $2.to_i
          day = $3.to_i
          life = $4.to_i
          remain = $5.to_i
        end
      end
      pm = PmCode.find_by_name name
      self.counters.find_or_create_by(pm_code_id: pm.id, value: counter, unit: 'counter')
    end # codes.each
    return "22-6 file processed."
  else
    return nil
  end
end
