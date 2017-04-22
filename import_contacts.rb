csv_file = ARGV.shift
if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [crm_objectid,contact_name,contactPhone]
  end

  r.each do |row|
    name = (row.contact_name.nil? or row.contact_name.empty?) ? 'Anonymous' : row.contact_name
    c = Contact.find_by_name_and_phone1(name, row.contactPhone)
    if (c.nil?)
      c = Contact.create(:name => name, :phone1 => row.contactPhone, :crm_object_id => row.crm_objectid)
    end
  end
else
  puts "Can't find or open #{csv_file}"
end
