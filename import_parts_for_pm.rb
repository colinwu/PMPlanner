if Part.all.size == 0
  puts "You must populate the Parts table first. Run import_parts.rb."
  exit
end
if ModelGroup.all.size == 0
  puts "You must populate the ModelGroup table first. Run import_model_group.rb."
  exit
end

csv_file = ARGV.shift
if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [model,pm,choice,part,quantity]
  end

  r.each do |row|
    g = ModelGroup.find_by name: row.model
    pm = PmCode.find_by name: row.pm
    p = Part.find_by name: row.part
    if (p.nil? or pm.nil? or g.nil?)
      puts "Something in row #{row.to_s} is not in the database."
      next
    end
    pmp = PartsForPm.where("model_group_id = #{g.id} and pm_code_id = #{pm.id} and part_id = #{p.id}")
    if pmp.empty?
      pmp = PartsForPm.create(:model_group_id => g.id, :pm_code_id => pm.id, :part_id => p.id, :choice => row.choice, :quantity => row.quantity )
    end
  end
else
  puts "Can't find or open #{csv_file}"
end
