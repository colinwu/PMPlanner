csv_file = ARGV.shift
if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [crm_objectid,order,contact_name,contactPhone,contactCellPhone,contactNotes]
  end

  r.each do |row|
    c = Contact.find_by_name_and_phone1(row.contact_name, row.contactPhone)
    if (c.nil?)
      c = Contact.create(:name => row.contact_name, :phone1 => row.contactPhone, :phone2 => row.contactCellPhone, :notes => row.contactNotes, :crm_object_id => row.crm_objectid)
    end
  end
else
  puts "Can't find or open #{csv_file}"
end
