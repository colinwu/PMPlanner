# Updates Location and Client models in addition to Device.

csv_file = ARGV.shift

if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    [crm_objectid, model, serialnumber, jt_equipid, soldtoid, soldtoname, addcontactid, addcontactname, address1, address2, city, province, postalcode, dealerid, dealername, serviceorgid, serviceorg, primarytechid, backuptechid, accountmgrid, accountmgr, inactive, nocontract, nopm]
    start_at_row 1
#     read_attributes_from_file
  end
  
  r.each do |row|
    # Ignore device if no soldtoid
    unless row.soldtoid.nil?
      # find or create the client record
      client = Client.find_by soldtoid: row.soldtoid
      if client.nil?
        client = Client.create(:name => row.soldtoname, :soldtoid => row.soldtoid)
      else
        client.update_attributes(name: row.soldtoname)
      end
      # find or create the location record
      loc = Location.where(["address1 = ? and address2 = ? and city = ? and province = ? and post_code = ? and client_id = ? and team_id = ?", row.address1, row.address2.nil? ? '' : row.address2, row.city, row.province, row.postalcode, client.id, row.serviceorgid]).first
      if loc.nil?
        loc = Location.create(:notes => row.addcontactname, :address1 => row.address1, :address2 => row.address2.nil? ? '' : row.address2, :city => row.city, :province => row.province, :post_code => row.postalcode, :team_id => row.serviceorgid, :client_id => client.id)
      end
      
      # find the device, model and techs for the device
      dev = Device.find_by_crm_object_id(row.crm_objectid)
      m = Model.find_by_nm(row.model)
      if m.nil?
        mg = ModelGroup.find_by_name 'OTHERS'
        m = mg.models.create(nm: row.model)
      end
      primary_tech = Technician.find_by_crm_id(row.primarytechid)
      backup_tech = Technician.find_by_crm_id(row.backuptechid)
      if (row.serviceorgid != '61000184' and row.serviceorg != 'Not assigned')
        if primary_tech.nil?
          puts "Primary tech (#{row.primarytechid}) for #{row.crm_objectid} in #{row.serviceorg} is not in the database."
        end
        if backup_tech.nil?
          puts "Backup tech (#{row.backuptechid}) for #{row.crm_objectid} in #{row.serviceorg} is not in the database."
        end
      end
      
      # team_id == 61000184 means it's a dealer, then make the dealer the primary tech
      if (row.serviceorgid == '61000184')
        primary_tech = Technician.find_by_crm_id(row.dealerid)
        if (primary_tech.nil?)
          primary_tech = Technician.create(
              crm_id: row.dealerid,
              first_name: row.dealername,
              last_name: 'Dealer',
              email: 'nobody@sharpsec.com',
              friendly_name: row.dealername
            )
        end
      end
      if dev.nil?
        if dev = Device.create(:crm_object_id => row.crm_objectid, 
                          :model_id => m.id,
                          :serial_number => row.serialnumber, 
                          :location_id => loc.id,
                          :primary_tech_id => primary_tech.try(:id),
                          :backup_tech_id => backup_tech.try(:id),
                          :active => (row.inactive == '0') ? true : false,
                          :under_contract => (row.nocontract == '0') ? true : false,
                          :do_pm => (row.nopm == '0') ? true : false,
                          :client_id => client.id,
                          :team_id => row.serviceorgid,
                          :pm_counter_type => 'counter',
                          :pm_visits_min => 2
                          )
          dev.create_neglected(next_visit: nil)
          dev.create_device_stat()
          dev.model.model_group.model_targets.where("maint_code <> 'AMV' and target > 0").each do |t|
            op = OutstandingPm.find_or_create_by(device_id: dev.id, code: t.maint_code)
            op.update_attributes(next_pm_date: Date.today)
          end
        else
          puts "Error creating device #{dev.crm_objectid}: #{dev.errors.to_s}"
        end
      else # if the device is already in the db
        dev.update_attributes(:crm_object_id => row.crm_objectid, 
                              :model_id => m.id,
                              :serial_number => row.serialnumber, 
                              :location_id => loc.id,
                              :primary_tech_id => primary_tech.try(:id),
                              :backup_tech_id => backup_tech.try(:id),
                              :active => (row.inactive == '0') ? true : false,
                              :under_contract => (row.nocontract == '0') ? true : false,
                              :do_pm => (row.nopm == '0') ? true : false,
                              :client_id => client.id,
                              :team_id => row.serviceorgid,
                              :pm_counter_type => 'counter',
                              :pm_visits_min => 2
                            )
      end
#       contacts = Contact.where("crm_object_id = #{row.crm_objectid}")
#       unless (contacts.empty? or dev.nil?)
#         contacts.each do |c|
#           c.update_attribute(:location_id, loc.id)
#         end
#       end
    end
  end
else
  puts "Can not open #{csv_file}"
end
