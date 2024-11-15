seen = ["-1"]
to_be_destroyed = []
Device.all.each do |d|
  unless (seen.include?(d.crm_object_id))
    dl = Device.where("crm_object_id = #{d.crm_object_id}").order(:created_at)
    if dl.count > 1
      # Reassign readings from the earlier device(s) to the last one
      lastdev = dl.last
      print("#{lastdev.id} started with #{lastdev.readings.count} readings...\n")
      dl.each do |dup|
        unless dup.id == lastdev.id
          dup.readings.each do |r|
            print("Reassigning #{r.id} from #{dup.id} to #{lastdev.id}\n")
            if r.technician_id.nil?
              r.update!(technician_id: 1)
            end
            unless r.update(device_id: lastdev.id)
              print("Problem updating Reading #{r.id} for device #{dup.serial_number}\n")
              exit
            end
          end
          print("Marking dev #{dup.id} for deletion.\n")
          to_be_destroyed << dup.id
        end
      end
      print("#{lastdev.id} now has #{lastdev.readings.count} readings.\n\n")
    end
  end
end
to_be_destroyed.each do |id|
  print("Destroy device #{id}\n")
  begin
    Device.find(id).destroy
  rescue
  end
end