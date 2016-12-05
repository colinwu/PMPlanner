csv_file = ARGV.shift
if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [model,group]
  end
  
  r.each do |row|
    mg = ModelGroup.find_by_name(row.group)
    if mg.nil?
      mg = ModelGroup.create(:name => row.group)
    end
    if Model.find_by_name(row.model).nil?
      mg.models.create(:name => row.model)
    end
  end
else
  puts "#{csv_file} not found."
end