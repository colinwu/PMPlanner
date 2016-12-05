if Team.all.size == 0
  puts "You must populate the Team table first. Run import_regions.rb."
  exit
end

csv_file = ARGV.shift
if (File.exists?(csv_file))
  r = CsvMapper.import(csv_file) do 
    start_at_row 1
    [computer_name,it_name,friendly_name,first_name,last_name,full_name,region,team_id,crm_id,car_stock_number,email]
  end
  r.each do |row|
    team = Team.find_by_team_id(row.team_id)
    if team.nil?
      team = Team.create(:team_id => row.team_id, :name => row.region)
    end
    if Technician.find_by_crm_id(row.crm_id).nil?
      row.email =~ /^([^@]+)@/
      sharpname = "sec\\" + $1
      team.technicians.create(:crm_id => row.crm_id, :first_name => row.first_name, :last_name => row.last_name, :friendly_name => row.friendly_name, :email => row.email, :car_stock_number => row.car_stock_number, :sharp_name => sharpname)
    end
  end
else
  puts "#{csv_file} does not exist."
end
