msg_list = {}
Log.where("technician_id <> 1 and message regexp 'Updated device with'").order('created_at desc').each do |m|
  if (not m.device.nil? and not msg_list[m.device.crm_object_id])
    if m.message =~ /("active\"=>\"\d\", \"under_contract\"=>\"\d\", \"do_pm\"=>\"\d\")/
      msg_list[m.device.crm_object_id] = $1
    end
  end
end

msg_list.each_pair do |d,m|
  m =~ /"active\"=>\"(\d)\", \"under_contract\"=>\"(\d)\", \"do_pm\"=>\"(\d)\"/
  dev = Device.find_by crm_object_id: d
  dev.update_attributes(active: ($1 == "1") ? true : false, 
                under_contract: ($2 == "1") ? true : false, 
                         do_pm: ($3 == "1") ? true : false)

  Log.create(technician_id: 1, device_id: dev.id, message: "Tech-set status: #{m}")
end