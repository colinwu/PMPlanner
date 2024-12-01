class AdminController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news, :require_manager
  
  def index
    you_are_here
  end

  def new

  end
  
  def eq_update    
    title = "Update Equipment Table"
    csv_file = params[:megan].to_path().to_s
    # There is a tempfile at uploaded_file.tempfile
    now = Time.now   # remember when the script started
    dev_list = Array.new()  # keep list of all CRM ids in this update
  #   r = CsvMapper.import(csv_file.to_path().to_s) do
  #     [crm_objectid, model, serialnumber, jt_equipid, soldtoid, soldtoname, addcontactid, addcontactname, address1, address2, city, province, postalcode, dealerid, dealername, serviceorgid, serviceorg, primarytechid, backuptechid, accountmgrid, accountmgr, inactive, nocontract, nopm]
  #     start_at_row 1
  # #     read_attributes_from_file
  #   end
  
    # Use CSV module instead of Csv-Mapper. The latter crashes in production!
    r = CSV.read(csv_file, headers: true, header_converters: :symbol)
    @messages = Array.new
    Log.create(technician_id: '1', message: "Updatig Equipment Tables from #{csv_file}.")
    r.each do |row|
      new_model_flag = false
      dev_list << row[:equipment_id]
      # Ignore device if no soldtoid
      unless row[:eq_soldto_party].nil?
        # strip leading and trailing white spaces
        row.each_pair {|k,v| row[k].nil? ? '' : row[k].strip!}

        # find or create the client record
        client = Client.find_by soldtoid: row[:eq_soldto_party]
        if client.nil?
          client = Client.create(name: (row[:address_line_0] || row[:bp_firrst_name]), soldtoid: row[:eq_soldto_party])
        else
          client.update(name: (row[:address_line_0] || row[:bp_firrst_name]))
        end
        # find or create the location record
        loc = Location.where(["address1 = ? and address2 = ? and city = ? and province = ? and post_code = ? and client_id = ?", row[:street_1], row[:street_2].nil? ? '' : row[:street_2], row[:city], row[:region], row[:postal_code], client.id]).first
        if loc.nil?
          loc = Location.create(:notes => row[bp_firrst_name], :address1 => row[street_1], :address2 => row[street_2].nil? ? '' : row[street_2], :city => row[:city], :province => row[:region], :post_code => row[:postal_code], :client_id => client.id, :team_id => row[ :eq_employee_grp])
          unless loc.errors.messages.empty?
            @messages << "Device #{row[:equipment_id]} Location errors: #{loc.errors.messages}"
          end
        end
        
        # find the device, model and techs for the device
        valid_sn = true
        if row[:serial_no].nil? or row[:serial_no].length < 8 or row[:serial_no].length > 9
        #  puts "Device #{row[:equipment_id]} has funny serial number: #{row[:serial_no]}"
          valid_sn = false
        end
        if row[:serial_no].length == 7
          row[:serial_no] = "0#{row[:serial_no]}"
          valid_sn = true
        end
        # dev = Device.find_by_crm_object_id(row[:equipment_id])

        # watch out for '-EMLD' being appended to Emerald models
        
        if row[:equip_model] =~ /-EMLD$/
          row[:equip_model].sub!(/-EMLD/,'')
        end
        m = Model.find_by_nm(row[:equip_model])
        if m.nil?
          new_model_flag = true
          mg = ModelGroup.find_by_name 'OTHERS'
          m = mg.models.create(nm: row[:equip_model])
        end
        primary_tech = Technician.find_by_crm_id(row[:eq_preferred_technician])
        backup_tech = Technician.find_by_crm_id(row[:eq_backup_technician])
        if (row[:eq_employee_grp] != '61000184' and row[:team] != 'Not assigned')
          if primary_tech.nil? and not row[:eq_preferred_technician].nil?
            @messages << "Primary tech (#{row[:eq_preferred_technician]}) for #{row[:equipment_id]} in #{row[:team]} is not in the database."
          else
            # if !primary_tech.nil? and (primary_tech.team_id != row[ :eq_employee_grp].to_i)
            #   primary_tech.logs.create(message: "Tech moved from #{primary_tech.team.name} to #{row[:team]}")
            #   primary_tech.update(team_id: row[ :eq_employee_grp])
            # end
          end
          if backup_tech.nil? and not row[:eq_backup_technician].nil?
            @messages << "Backup tech (#{row[:eq_backup_technician]}) for #{row[:equipment_id]} in #{row[:team]} is not in the database."
          else
            # if !backup_tech.nil? and (backup_tech.team_id != row[ :eq_employee_grp].to_i)
            #   backup_tech.logs.create(message: "Tech moved from #{backup_tech.team.name} to #{row[:team]}")
            #   backup_tech.update(team_id: row[ :eq_employee_grp])
            # end
          end
        end
        
        # team_id == 61000184 means it's a dealer, then make the dealer the primary tech
        if (row[:eq_employee_grp] == '61000184')
          primary_tech = Technician.find_by_crm_id(row[:eq_servicing_dealer])
          if (primary_tech.nil? and !row[:eq_preferred_technician].nil?)
            primary_tech = Technician.create(
                crm_id: row[:eq_servicing_dealer],
                first_name: row[:dealer],
                last_name: 'Dealer',
                email: 'nobody@sharpsec.com',
                friendly_name: row[:dealer],
                team_id: row[:eq_employee_grp]
            )
            primary_tech.create_preference(
              upcoming_interval: 2
            )
          end
        end
        dev = Device.where(["model_id = ? and serial_number = ? and active = true and crm_object_id = ?",m.id, row[:serial_no], row[:equipment_id]]).last
        if dev.nil?   # new device
          if dev = Device.create(:crm_object_id => row[:equipment_id], 
                            :model_id => m.id,
                            :serial_number => row[:serial_no], 
                            :location_id => loc.id,
                            :primary_tech_id => primary_tech.try(:id),
                            :backup_tech_id => backup_tech.try(:id),
                            :crm_active => (row[:inactive] == '0' or row[:inactive] =~ /FALSE/i) ? true : false,
                            :active => (row[:inactive] == '0' or row[:inactive] =~ /FALSE/i) ? true : false,
                            :crm_under_contract => (row[:nocontract] == '0' or row[:nocontract] =~ /FALSE/i) ? true : false,
                            :under_contract => (row[:nocontract] == '0' or row[:nocontract] =~ /FALSE/i) ? true : false,
                            :crm_do_pm => (row[:nopm] =~ /TRUE/i or row[:nopm] == '1') ? false : true,
                            :do_pm => (row[:nopm] =~ /TRUE/i or row[:nopm] == '1') ? false : true,
                            :client_id => client.id,
                            :team_id => row[:eq_employee_grp],
                            :pm_counter_type => 'counter',
                            :pm_visits_min => 2,
                            :acctmgr => row[:eq_account_mgr]
                            )
            # dev.create_neglected(next_visit: nil)
            unless dev.valid?
              @messages << "Device invalid: #{row[:equipment_id]}, #{dev.errors.messages}"
              Log.create(technician_id: 1, message: "Device invalid: #{row[:equipment_id]}, #{dev.errors.messages}")
              next
            end
            dev.create_device_stat()
            dev.model.model_group.model_targets.where("maint_code <> 'AMV' and target > 0").each do |t|
              op = OutstandingPm.find_or_create_by(device_id: dev.id, code: t.maint_code)
              op.update(next_pm_date: Date.today)
            end
            dev.logs.create(technician_id: 1, message: "New device added with sn #{dev.serial_number}.")
            if new_model_flag
              dev.logs.create(technician_id: 1, message: "New model #{row[:equip_model]} assigned to Model Group 'OTHER'")
            end
          else
            @messages << "Error creating device #{dev[:equipment_id]}: #{dev.errors.to_s}"
          end
        else # if the device is already in the db
          if dev.crm_object_id == '-1'
            dev.logs.create(message: "Device s/n #{row[:serial_no]} assigned CRM ID #{row[:equipment_id]}")
          end
          dev.update(:crm_object_id => row[:equipment_id], 
                      :model_id => m.id,
                      :serial_number => row[:serial_no], 
                      :location_id => loc.id,
                      :primary_tech_id => primary_tech.try(:id),
                      :backup_tech_id => backup_tech.try(:id),
                      :crm_active => (row[:inactive] == '0' or row[:inactive] =~ /FALSE/i) ? true : false,
                      :active => (row[:inactive] == '0' or row[:inactive] =~ /FALSE/i) ? true : false,
                      :crm_under_contract => (row[:nocontract] == '0' or row[:nocontract] =~ /FALSE/i) ? true : false,
                      :crm_do_pm => (row[:nopm] =~ /TRUE/i or row[:nopm] == '1') ? false : true,
                      :client_id => client.id,
                      :team_id => row[:eq_employee_grp],
                      :pm_counter_type => 'counter',
                      :pm_visits_min => 2,
                      :acctmgr => row[:eq_account_mgr]
                    )
        end
      end
    end

    dev_list_s = dev_list.join(',')
    not_in = Device.where("crm_object_id not in (#{dev_list_s})")
    not_in.each do |d|
      if d.under_contract
        @messages << "Device #{d.crm_object_id} (s/n #{d.serial_number}) not in current feed. Its current contract status is #{d.under_contract}"
        d.logs.create(technician_id: 1, message: "Device not in current feed. Its current contract status is #{d.crm_under_contract} - changing to FALSE.")
      end
      d.update(crm_under_contract: false, under_contract: false, active: false) 
    end
    @messages << "There were #{not_in.count} devices not in the current feed."

  end
end
