# Find and remove devices (and their associated counter data) that are at least one year old and
# either still have no data OR the last counter data collected was more than a year ago
#
# The records are saved to text files in json format for later retrieval if necessary.

one_yr_ago = Date.today().years_ago(1)
devs_f = File.new("abandoned_devices.json", "w")
readings_f = File.new("abandoned_readings.json", "w")
counts_f = File.new("abandoned_counters.json", "w")
Device.where("crm_under_contract = false").each do |dev|
  if dev.readings.empty?
    if dev.created_at < one_yr_ago
      puts "#{dev.crm_object_id}, #{dev.try(:primary_tech).try(:friendly_name)} and #{dev.try(:backup_tech).try(:friendly_name)}: has no readings."
      devs_f.puts dev.to_json
      dev.destroy
    end
  else
    r = dev.readings.order(:taken_at)
    if r.last.taken_at < one_yr_ago
      puts "#{dev.crm_object_id}, #{dev.try(:primary_tech).try(:friendly_name)} and #{dev.try(:backup_tech).try(:friendly_name)}: last reading on #{r.last.taken_at}"
      devs_f.puts dev.to_json
      r.each do |reading|
        readings_f.puts reading.to_json
        reading.counters.each do |c|
          counts_f.puts c.to_json
        end
        reading.destroy
      end
      dev.destroy
    end
  end
end
