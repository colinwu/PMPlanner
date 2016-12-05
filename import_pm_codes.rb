csv_file = ARGV.shift
if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [id,name,description,colorclass,label,section]
  end

  r.each do |row|
    p = PmCode.find_by_name row.name
    if (p.nil?)
      p = PmCode.create(:name => row.name, :description => row.description, :colorclass => row.colorclass, :label => row.label, :section => row.section)
    end
  end
else
  puts "Can't find or open #{csv_file}"
end
