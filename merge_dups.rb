to_be_destroyed = Array.new()
Device.where("length(serial_number) = 7").each do |nzd|
  zd = Device.find_by_serial_number("0#{nzd.serial_number}")
  unless zd.nil?
    nzsn = nzd.serial_number
    sn  = zd.serial_number
    if nzd.readings.count != 0 or zd.readings.count != 0
      puts("")
      puts("SN #{zd.serial_number} id #{zd.id} created #{zd.created_at} and has #{zd.readings.count} readings")
      puts("SN  #{nzd.serial_number} id #{nzd.id} created #{nzd.created_at} and has #{nzd.readings.count} readings")
      
      if zd.created_at > nzd.created_at
        # zd was created AFTER d. Move associated readings etc from nzd to zd
        nzd.outstanding_pms.update_all(device_id: zd.id)
        unless nzd.neglected.nil?
          nzd.neglected.update(device_id: zd.id)
        end
        unless nzd.device_stat.nil?
          nzd.device_stat.update(device_id: zd.id)
        end
        nzd.readings.update_all(device_id: zd.id)
        # nzd.readings.each do |r|
        #   puts "A: updating reading #{r.id}"
        #   unless r.update(device_id: d.id)
        #     puts "Problem updating reading #{r.id}"
        #   end
        # end

        to_be_destroyed << nzd.id
      else
        # move associated readings etc from zd to nzd and add a leading zero to nzd's sn
        zd.outstanding_pms.update_all(device_id: nzd.id)
        unless zd.neglected.nil?
          zd.neglected.update(device_id: nzd.id)
        end
        unless zd.device_stat.nil?
          zd.device_stat.update(device_id: nzd.id)
        end
        nzd.update(serial_number: zd.serial_number)
        zd.readings.update_all(device_id: nzd.id)
        # d.readings.each do |r|
        #   puts "B: updating reading #{r.id}"
        #   unless r.update!(device_id: nzd.id)
        #     puts "Problem updating reading #{r.id}"
        #   end
        # end

        to_be_destroyed << zd.id
      end
    end
  else
    puts ("No record found for device with SN 0#{nzd.serial_number}. Adjusting existing serial number.")
    nzd.update(serial_number: "0#{nzd.serial_number}")
  end
end

Device.destroy(to_be_destroyed)
