csv_file = ARGV.shift
if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [number,description,price,newname]
  end

  r.each do |row|
    p = Part.find_by_name row.number
    if (p.nil?)
      p = Part.create(:name => row.number, :description => row.description, :price => row.price, :new_name => row.newname)
    end
  end
else
  puts "Can't find or open #{csv_file}"
end
