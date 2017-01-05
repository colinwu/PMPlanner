# Updates Location and Contact models in addition to Device. Contact should already exist
if Contact.all.size == 0
  puts "You must first import Contacts: run import_contacts.rb"
  exit
end

csv_file = ARGV.shift

if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    # crm_objectid, model, serialnumber, jt_equipid, soldtoid, soldtoname, addcontactid, addcontactname, address1, address2, city, province, postalcode, serviceorgid, serviceorg="SD Ottawa", primarytechid, backuptechid, accountmgrid, accountmgr, equipnotes, inactive, nocontract, nopm
    read_attributes_from_file
  end
  
  r.each do |row|
    # Ignore device if no soldtoid
    unless row.soldtoid.nil?
      client = Client.find_by_soldtoid row.soldtoid
      if client.nil?
        client = Client.create(:name => row.soldtoname, :soldtoid => row.soldtoid)
      end
      loc = Location.where(["address1 = ? and address2 = ? and city = ? and province = ? and post_code = ? and client_id = ? and team_id = ?", row.address1, row.address2.nil? ? '' : row.address2, row.city, row.province, row.postalcode, client.id, row.serviceorgid]).first
      if loc.nil?
        loc = Location.create(:notes => row.addcontactname, :address1 => row.address1, :address2 => row.address2.nil? ? '' : row.address2, :city => row.city, :province => row.province, :post_code => row.postalcode, :team_id => row.serviceorgid, :client_id => client.id)
      end
      
      dev = Device.find_by_crm_object_id(row.crm_objectid)
      m = Model.find_by_nm(row.model)
      if m.nil?
        puts "Model #{row.model} not found."
        next;
      end
      primary_tech = Technician.find_by_crm_id(row.primarytechid)
      backup_tech = Technician.find_by_crm_id(row.backuptechid)
      
      # Ignore device if no techs assigned
      if dev.nil?
        unless (primary_tech.nil? or backup_tech.nil? or row.primarytechid.nil? or row.backuptechid.nil?)
          dev = Device.create(:crm_object_id => row.crm_objectid, 
                            :model_id => m.id,
                            :serial_number => row.serialnumber, 
                            :location_id => loc.id,
                            :primary_tech_id => row.primarytechid.nil? ? nil : primary_tech.id,
                            :backup_tech_id => row.backuptechid.nil? ? nil : backup_tech.id,
                            :active => (row.inactive == '0') ? true : false,
                            :under_contract => (row.nocontract == '0') ? true : false,
                            :do_pm => (row.nopm == '0') ? true : false,
                            :notes => row.equipnotes, 
                            :client_id => client.id,
                            :team_id => row.serviceorgid,
                            :pm_counter_type => 'counter'
                            )
        end
      else
        dev.update_attributes(:crm_object_id => row.crm_objectid, 
                              :model_id => m.id,
                              :serial_number => row.serialnumber, 
                              :location_id => loc.id,
                              :primary_tech_id => row.primarytechid.nil? ? nil : primary_tech.id,
                              :backup_tech_id => row.backuptechid.nil? ? nil : backup_tech.id,
                              :active => (row.inactive == '0') ? true : false,
                              :under_contract => (row.nocontract == '0') ? true : false,
                              :do_pm => (row.nopm == '0') ? true : false,
                              :notes => row.equipnotes, 
                              :client_id => client.id,
                              :team_id => row.serviceorgid,
                              :pm_counter_type => 'counter'
                             )
      end
      contacts = Contact.where("crm_object_id = #{row.crm_objectid}")
      unless (contacts.empty? or dev.nil?)
        contacts.each do |c|
          c.update_attribute(:location_id, loc.id)
        end
      end
    end
  end
else
  puts "Can not open #{csv_file}"
end
