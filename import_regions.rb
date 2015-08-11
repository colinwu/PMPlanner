csv_file = ARGV.shift
if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [crm_region_id,crm_regionName,regionName,warehouse_id]
  end

  r.each do |row|
    t = Team.find_by_team_id(row.crm_region_id)
    if t.nil?
      Team.create(:team_id => row.crm_region_id, :crm_name => row.crm_regionName, :name => row.regionName, :warehouse_id => row.warehouse_id)
    end
  end
else
  puts "Can't find or open #{csv_file}"
end
