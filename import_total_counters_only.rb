 
if Device.all.size == 0
  puts "You must populate the Device table first. Run import_equipment_base.rb."
  exit
end

csv_file = ARGV.shift
if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [crmid,taken_at,bwtotal,ctotal]
  end
  
  r.each do |row|
    dev = Device.find_by_crm_object_id row['crmid']
    if dev.nil?
      puts "Could not find device with CRM ID: #{row.crmid} date: #{row.taken_at}"
      next
    end
    taken_at = row.taken_at.split('-').reverse.join('-')
    tech = dev.primary_tech
    if tech.nil?
      puts "Could not find primary tech for device #{row.crmid}"
      next
    end
    readings = dev.readings.where(["taken_at = ?", taken_at])
    if readings.empty?
      r = dev.readings.create(technician_id: tech.id, taken_at: taken_at)
    else
      r = readings.first
      r.update_attributes(technician_id: tech.id, taken_at: taken_at)
      r.save
    end
    all_codes = dev.model.model_group.model_targets.map do |t|
      if !t.target.nil? and t.target > 0
        t.maint_code
      end
    end
    all_codes.delete(nil)
    all_codes.delete('AMV')
    all_codes.each do |c|
      code = PmCode.find_by(name: c)
      r.counters.create(pm_code_id: code.id, value: 0, unit: 'counter')
    end
    ['bwtotal', 'ctotal'].each do |c|
      code = PmCode.find_by(name: c)
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
