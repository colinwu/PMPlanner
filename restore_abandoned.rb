# To restore data for an individual device with provided crm_object_id. Any counter data
# associated with the device are also restored.

crm_object_id = ARGV.shift
df = File.open("abandoned_devices.json","r")
rf = File.open("abandoned_readings.json","r")
dev_id = 0
read_id = 0
d = Device.new
while (dev_json = df.gets)
  if dev_json.match(/"crm_object_id":"#{crm_object_id}",/)
    d.from_json(dev_json)
    # dev_id = dev_json.match(/"id":(\d+),/)[1].to_i
    d.save(validate: false)
    dev_id = d.id
    puts "Device #{dev_id} (crm id: #{crm_object_id} restored..."
    break
  end
end
df.close

if dev_id > 0
  puts "  Readings for device #{crm_object_id }"
  puts "  =================================="
  while (read_json = rf.gets)
    if read_json.match(/"device_id":#{dev_id},/)
      puts "  " + read_json
      r = Reading.new.from_json(read_json)
      read_id = r.id
      unless r.save(validate: false)
        puts "Unable to save Reading"
        break
      end
      puts "    Counters for reading"
      puts "    ===================="
      cf = File.open("abandoned_counters.json","r")
      count_id = 0
      while (count_json = cf.gets)
        if count_json.match(/"reading_id":#{read_id},/)
          puts "    " + count_json
          c = Counter.new.from_json(count_json)
          count_id = c.id
          c.save(validate: false)
        elsif count_id > 0
          break
        end
      end
      cf.close
    # elsif read_id > 0
    #   break
    end
  end
end

unless d.id.nil?
  begin
    d.update_pm_visit_tables
  rescue
    puts "Could not update outstanding PM table."
  end
end