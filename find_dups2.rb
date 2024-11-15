csv_file = '/home/wucolin/BW export for PM planner 2024-08-22.csv'
dev_list = Array.new()  # keep list of all CRM ids in this update
r = CsvMapper.import(csv_file) do
  [crm_objectid, model, serialnumber, jt_equipid, soldtoid, soldtoname, addcontactid, addcontactname, address1, address2, city, province, postalcode, dealerid, dealername, serviceorgid, serviceorg, primarytechid, backuptechid, accountmgrid, accountmgr, inactive, nocontract, nopm]
  start_at_row 1
end

valid_dev = Device.new()
r.each do |row|
  dev_list << row.crm_objectid
  if row.model =~ /-EMLD$/
    row.model.sub!(/-EMLD/,'')
  end
  if row.serialnumber.length == 7
    dl = Device.joins(:model).where(["(serial_number = ? or serial_number = ?) and models.nm = ?", row.serialnumber, "0#{row.serialnumber}", row.model])
  else
    dl = Device.joins(:model).where(["serial_number = ? and models.nm = ?", row.serialnumber, row.model])
  end
  if dl.count > 1
    puts("SN: #{row.serialnumber}, model: #{row.model} has #{dl.count} records:")
    dl.each do |dev|
      if dev.crm_object_id == row.crm_objectid
        valid_dev = dev
        puts("CRM ID #{dev.crm_object_id}, created: #{dev.created_at} last used #{dev.updated_at} is in the feed")
        # dev.update(active: true, crm_active: true)
      else
        puts("CRM ID #{dev.crm_object_id}, created: #{dev.created_at} last used #{dev.updated_at} is NOT in the feed")
        if dev.crm_object_id == '-1'
          dev.readings.each do |r|
            puts("  Moving reading #{r.id} taken at #{r.taken_at} from #{dev.id} to #{valid_dev.id}")
            if valid_dev.readings.find_by_taken_at(r.taken_at).nil?
              r.update(device_id: valid_dev.id)
            else
              puts("    Reading already exists.")
              r.destroy
            end
          end
        end
        dev.update(active: false, crm_active: false)
      end
      # lastread = dev.readings.order(:taken_at).last
      # puts("  Last reading: #{lastread.try(:taken_at)}")
    end
    puts("")
  end
end
