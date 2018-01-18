csv_file = ARGV.shift
if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [crm_object_id, installed]
  end

  r.each do |row|
    d = Device.find_by crm_object_id: row.crm_object_id
    unless d.nil?
      begin
        install_date = Date.parse(row.installed)
      rescue
        unless (row.installed =~ /#/)
          puts "#{row.num}: #{row.installed} is not a valid date."
        end
        next
      end
      d.update_attributes(install_date: install_date)
    else
      puts "#{row.crm_object_id} not found in database."
    end
  end
end