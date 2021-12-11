# Updates Location and Client models in addition to Device.
require 'getopt/std'
opt = Getopt::Std.getopts('Y')
if opt['Y']
  # don't bother asking
else
  puts "\n      **** WARNING **** WARNING **** WARNING ****"
  puts "\nThe data file you are using MUST contain ALL devices that currently exist in CRM \nor *** BAD *** things will happen."
  puts "\nDo you want to continue? [y/N]"
  ans = STDIN::getc
  unless ans == 'y' or ans == 'Y'
    exit
  end
end

csv_file = ARGV.shift

if File.exists?(csv_file)
  now = Time.now   # remember when the script started
  dev_list = Array.new()  # keep list of all CRM ids in this update
  r = CsvMapper.import(csv_file) do
    [crm_objectid, model, serialnumber, jt_equipid, soldtoid, soldtoname, addcontactid, addcontactname, address1, address2, city, province, postalcode, dealerid, dealername, serviceorgid, serviceorg, primarytechid, backuptechid, accountmgrid, accountmgr, inactive, nocontract, nopm]
    start_at_row 1
#     read_attributes_from_file
  end
  
  Log.create(technician_id: '1', message: "Updatig Equipment Tables from #{csv_file}.")
  r.each do |row|
    new_model_flag = false
    dev_list << row.crm_objectid
    # Ignore device if no soldtoid
    unless row.soldtoid.nil?
      # strip leading and trailing white spaces
      row.each_pair {|k,v| row[k].nil? ? '' : row[k].strip!}

      # find or create the client record
      client = Client.find_by soldtoid: row.soldtoid
      if client.nil?
        client = Client.create(name: (row.soldtoname || row.addcontactname), soldtoid: row.soldtoid)
      else
        client.update(name: (row.soldtoname || row.addcontactname))
      end
      # find or create the location record
      loc = Location.where(["address1 = ? and address2 = ? and city = ? and province = ? and post_code = ? and client_id = ?", row.address1, row.address2.nil? ? '' : row.address2, row.city, row.province, row.postalcode, client.id]).first
      if loc.nil?
        loc = Location.create(:notes => row.addcontactname, :address1 => row.address1, :address2 => row.address2.nil? ? '' : row.address2, :city => row.city, :province => row.province, :post_code => row.postalcode, :client_id => client.id, :team_id => row.serviceorgid)
        unless loc.errors.messages.empty?
          puts "Device #{row.crm_objectid} Location errors: #{loc.errors.messages}"
        end
      end
      
      # find the device, model and techs for the device
      valid_sn = true
      if row.serialnumber.nil? or row.serialnumber.length < 8 or row.serialnumber.length > 9
      #  puts "Device #{row.crm_objectid} has funny serial number: #{row.serialnumber}"
        valid_sn = false
      end
      dev = Device.find_by_crm_object_id(row.crm_objectid)

      # watch out for '-EMLD' being appended to Emerald models
      if row.model =~ /-EMLD$/
        row.model.sub!(/-EMLD/,'')
      end
      m = Model.find_by_nm(row.model)
      if m.nil?
        new_model_flag = true
        mg = ModelGroup.find_by_name 'OTHERS'
        m = mg.models.create(nm: row.model)
      end
      primary_tech = Technician.find_by_crm_id(row.primarytechid)
      backup_tech = Technician.find_by_crm_id(row.backuptechid)
      if (row.serviceorgid != '61000184' and row.serviceorg != 'Not assigned')
        if primary_tech.nil? and not row.primarytechid.nil?
          puts "Primary tech (#{row.primarytechid}) for #{row.crm_objectid} in #{row.serviceorg} is not in the database."
        else
          # if !primary_tech.nil? and (primary_tech.team_id != row.serviceorgid.to_i)
          #   primary_tech.logs.create(message: "Tech moved from #{primary_tech.team.name} to #{row.serviceorg}")
          #   primary_tech.update(team_id: row.serviceorgid)
          # end
        end
        if backup_tech.nil? and not row.backuptechid.nil?
          puts "Backup tech (#{row.backuptechid}) for #{row.crm_objectid} in #{row.serviceorg} is not in the database."
        else
          # if !backup_tech.nil? and (backup_tech.team_id != row.serviceorgid.to_i)
          #   backup_tech.logs.create(message: "Tech moved from #{backup_tech.team.name} to #{row.serviceorg}")
          #   backup_tech.update(team_id: row.serviceorgid)
          # end
        end
      end
      
      # team_id == 61000184 means it's a dealer, then make the dealer the primary tech
      if (row.serviceorgid == '61000184')
        primary_tech = Technician.find_by_crm_id(row.dealerid)
        if (primary_tech.nil? and !row.primarytechid.nil?)
          primary_tech = Technician.create(
              crm_id: row.dealerid,
              first_name: row.dealername,
              last_name: 'Dealer',
              email: 'nobody@sharpsec.com',
              friendly_name: row.dealername,
              team_id: row.serviceorgid
          )
          primary_tech.create_preference(
            upcoming_interval: 2
          )
        end
      end
      if dev.nil?   # new device
        if dev = Device.create(:crm_object_id => row.crm_objectid, 
                          :model_id => m.id,
                          :serial_number => row.serialnumber, 
                          :location_id => loc.id,
                          :primary_tech_id => primary_tech.try(:id),
                          :backup_tech_id => backup_tech.try(:id),
                          :crm_active => (row.inactive == '0'or row.inactive =~ /FALSE/i) ? true : false,
                          :active => (row.inactive == '0'or row.inactive =~ /FALSE/i) ? true : false,
                          :crm_under_contract => (row.nocontract == '0' or row.nocontract =~ /FALSE/i) ? true : false,
                          :under_contract => (row.nocontract == '0' or row.nocontract =~ /FALSE/i) ? true : false,
                          :crm_do_pm => (row.nopm =~ /TRUE/i or row.nopm == '1') ? false : true,
                          :do_pm => (row.nopm =~ /TRUE/i or row.nopm == '1') ? false : true,
                          :client_id => client.id,
                          :team_id => row.serviceorgid,
                          :pm_counter_type => 'counter',
                          :pm_visits_min => 2,
                          :acctmgr => row.accountmgr
                          )
          # dev.create_neglected(next_visit: nil)
          unless dev.valid?
            puts "Device invalid: #{row.crm_objectid}, #{dev.errors.messages}"
            Log.create(technician_id: 1, message: "Device invalid: #{row.crm_objectid}, #{dev.errors.messages}")
            next
          end
          dev.create_device_stat()
          dev.model.model_group.model_targets.where("maint_code <> 'AMV' and target > 0").each do |t|
            op = OutstandingPm.find_or_create_by(device_id: dev.id, code: t.maint_code)
            op.update(next_pm_date: Date.today)
          end
          dev.logs.create(technician_id: 1, message: "New device added.")
          if new_model_flag
            dev.logs.create(technician_id: 1, message: "New model #{row.model} assigned to Model Group 'OTHER'")
          end
        else
          puts "Error creating device #{dev.crm_objectid}: #{dev.errors.to_s}"
        end
      else # if the device is already in the db
        dev.update(:crm_object_id => row.crm_objectid, 
                              :model_id => m.id,
                              :serial_number => row.serialnumber, 
                              :location_id => loc.id,
                              :primary_tech_id => primary_tech.try(:id),
                              :backup_tech_id => backup_tech.try(:id),
                              :crm_active => (row.inactive == '0'or row.inactive =~ /FALSE/i) ? true : false,
                              :crm_under_contract => (row.nocontract == '0' or row.nocontract =~ /FALSE/i) ? true : false,
                              :crm_do_pm => (row.nopm =~ /TRUE/i or row.nopm == '1') ? false : true,
                              :client_id => client.id,
                              :team_id => row.serviceorgid,
                              :pm_counter_type => 'counter',
                              :pm_visits_min => 2,
                              :acctmgr => row.accountmgr
                            )
      end
    end
  end

  dev_list_s = dev_list.join(',')
  not_in = Device.where("crm_object_id not in (#{dev_list_s})")
  not_in.each do |d|
    if d.under_contract
      puts "Device #{d.crm_object_id} (s/n #{d.serial_number}) not in current feed. Its current contract status is #{d.under_contract}"
      d.logs.create(technician_id: 1, message: "Device not in current feed. Its current contract status is #{d.crm_under_contract} - changing to FALSE.")
    end
    d.update(crm_under_contract: false, under_contract: false) 
  end
  puts "There were #{not_in.count} devices not in the current feed."
else
  puts "Can not open #{csv_file}"
end
