with_zeros = Device.where("serial_number like '0%'")
# with_zeros = Device.where("serial_number = '05075412'")
to_be_destroyed = Array.new()
with_zeros.each do |d|
  sn = d.serial_number
  nzsn = sn[1,sn.length-1]
  nzd = Device.find_by_serial_number(nzsn)
  unless nzd.nil?
    if d.readings.count != 0 or nzd.readings.count != 0
      puts("")
      puts("SN #{d.serial_number} id #{d.id} created #{d.created_at} and has #{d.readings.count} readings")
      puts("SN  #{nzd.serial_number} id #{nzd.id} created #{nzd.created_at} and has #{nzd.readings.count} readings")
      
      if d.created_at > nzd.created_at
        # d was created AFTER nzd. Move associated readings etc from nzd to d
        nzd.outstanding_pms.update_all(device_id: d.id)
        unless nzd.neglected.nil?
          nzd.neglected.update(device_id: d.id)
        end
        unless nzd.device_stat.nil?
          nzd.device_stat.update(device_id: d.id)
        end
        nzd.readings.update_all(device_id: d.id)
        # nzd.readings.each do |r|
        #   puts "A: updating reading #{r.id}"
        #   unless r.update(device_id: d.id)
        #     puts "Problem updating reading #{r.id}"
        #   end
        # end

        to_be_destroyed << nzd.id
      else
        # move associated readings etc from d to nzd and add a leading zero to nzd's sn
        d.outstanding_pms.update_all(device_id: nzd.id)
        unless d.neglected.nil?
          d.neglected.update(device_id: nzd.id)
        end
        unless d.device_stat.nil?
          d.device_stat.update(device_id: nzd.id)
        end
        nzd.update(serial_number: d.serial_number)
        d.readings.update_all(device_id: nzd.id)
        # d.readings.each do |r|
        #   puts "B: updating reading #{r.id}"
        #   unless r.update!(device_id: nzd.id)
        #     puts "Problem updating reading #{r.id}"
        #   end
        # end

        to_be_destroyed << d.id
      end
    end
  end
end

Device.destroy(to_be_destroyed)
