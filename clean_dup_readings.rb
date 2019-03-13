# Clean up database by keeping only the latest reading for any date
Device.find_each do |d|
  if d.readings.count > 1
    grouped_readings = d.readings.group(:taken_at)
    grouped_readings.each do |r|
      one_day = d.readings.where("taken_at = '#{r.taken_at}'").order("created_at DESC")
      if one_day.count > 1
        for i in 1..(one_day.count-1)
          puts "Destroy reading #{one_day[i].id} taken at #{one_day[i].taken_at} (#{one_day[i].created_at}) for device #{d.id}"
          one_day[i].destroy
        end
        puts "Kept reading #{one_day[0].id} created at #{one_day[0].created_at}"
      end
    end
  end
end
