csv_file = ARGV.shift
if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [id,name,description,colorclass]
  end
  
  PmCode.find_or_create_by(name: 'BWTOTAL', description: 'Total BW Count', colorclass: 'ALL')
  PmCode.find_or_create_by(name: 'CTOTAL', description: 'Total Colour Count', colorclass: 'COLOR')
  r.each do |row|
    p = PmCode.find_by_name row.name
    if (p.nil?)
      p = PmCode.create(:name => row.name, :description => row.description, :colorclass => row.colorclass)
    end
  end
else
  puts "Can't find or open #{csv_file}"
end
