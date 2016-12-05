if Device.all.size == 0 or Technician.all.size == 0
  puts "You must populate the Device and Technician tables first. Run import_equipment_base.rb and import_tech.rb."
  exit
end

csv_file = ARGV.shift
if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [crmid,tech_id,notes,taken_at,bwtotal,ctotal,mreq,ta,ca,aa,drc,dvc,dk,dc,dm,dy,vk,vc,vm,vy,tk,tk1,tk2,fk,fk1,fk2,fk3]
  end
  i = 0
  total_rows = r.size
  c_labels = %w[bwtotal ctotal mreq ta ca aa drc dvc dk dc dm dy vk vc vm vy tk tk1 tk2 fk fk1 fk2 fk3] 
  r.each do |row|
    i += 1
    tech = Technician.find_by_crm_id row['tech_id']
    dev = Device.find_by_crm_object_id row['crmid']
    if dev.nil?
      puts "Could not find device with CRM ID: #{row.crmid}"
      next
    end
    if tech.nil?
      puts "Could not find tech with CRM ID: #{row.tech_id} for device #{row.crmid}"
      next
    end
    puts "#{i} of #{total_rows}. Device #{dev.id}"
    # See if there is a reading for the same device on the same date
    tmp = row.taken_at.split('/')
    taken_at = "#{tmp[2]}-#{tmp[0]}-#{tmp[1]}"
    readings = dev.readings.where(["taken_at = ?", taken_at])
    if readings.empty?
      r = dev.readings.create(technician_id: tech.id, notes: row.notes, taken_at: taken_at)
    else
      r = readings.first
      r.technician_id = tech.id
      r.notes = row.notes
      r.taken_at = taken_at
      r.save
    end
    c_labels.each do |c|
      code = PmCode.where("name = '#{c}'").first
#       next if row[c].to_i == 0
      datum = r.counters.where(["pm_codes.name = ?", c]).joins(:pm_code)
      if datum.empty?
        r.counters.create(pm_code_id: code.id, value: row[c].to_i, unit: 'counter')
      else
        d = datum.first
        d.value = row[c].to_i
        d.save
      end
    end
  end
else
  puts "Can't find or open #{csv_file}"
end
