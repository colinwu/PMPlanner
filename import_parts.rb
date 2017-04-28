csv_file = ARGV.shift
if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [part_number,description]
  end

  r.each do |row|
    p = Part.find_by_name row.part_number
    if (p.nil?)
      p = Part.new(:name => row.part_number, :description => row.description)
      unless p.save
        puts "Part is invalid: #{p.errors.messages}"
      end
    end
  end
else
  puts "Can't find or open #{csv_file}"
end
