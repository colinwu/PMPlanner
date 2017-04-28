csv_file = ARGV.shift
if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [crm_objectid,contact_name,contactPhone]
  end

  r.each do |row|
    if (row.contact_name.nil?) and (row.contactPhone.nil?)
      puts ("No name or phone # for device #{row.crm_objectid}")
      next
    end
    contactName = row.contact_name.nil? ? 'Anonymous' : row.contact_name
    c = Contact.find_by_name_and_phone1(contactName, row.contactPhone)
    if (c.nil?)
      c = Contact.new(:name => contactName, :phone1 => row.contactPhone)
    end
    d = Device.find_by_crm_object_id(row.crm_objectid)
    unless d.nil?
      c.location_id = d.location_id
      c.client_id = d.client_id
      unless c.save
        puts "Error saving contact #{c.name}: #{c.errors.messages}"
      end
    else
      puts "Device with CRM ID #{row.crm_objectid} not found."
    end
  end
else
  puts "Can't find or open #{csv_file}"
end
