csv_file = ARGV.shift
if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [id,name,description,colorclass]
  end

  r.each do |row|
    p = PMCode.find_by_name row.name
    if (p.nil?)
      p = PMCode.create(:name => row.name, :description => row.description, :colorclass => row.colorclass)
    end
  end
else
  puts "Can't find or open #{csv_file}"
end
