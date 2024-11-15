seen = ["-1"]
Device.all.each do |d|
  unless (seen.include?(d.crm_object_id))
    dl = Device.where("crm_object_id = #{d.crm_object_id}").order(:created_at)
    if dl.count > 1
      print("There are #{dl.count} devices with CRM ID #{d.crm_object_id}:\n")
      dl.each do |dup|
        print("ID: #{dup.id}, SN: #{dup.serial_number}, #{dup.model.nm}, #{dup.created_at}\n")
        seen << d.crm_object_id
      end
    end
  end
end