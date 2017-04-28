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
  if Technician.where(admin: true).empty? or Technician.find_by_sharp_name("sec\\wuc").nil?
    admin_team = Team.find_by_name('Admin')
    admin_user = Technician.create(crm_id: 1, first_name: 'Colin', last_name: 'Wu', friendly_name: 'Colin', email: 'wuc@sharpsec.com', admin: true, team_id: admin_team.team_id, sharp_name: 'sec\\wuc')
    admin_user.create_preference(
      limit_to_region: false, 
      limit_to_territory: false, 
      default_notes: "Entered by Colin Wu", 
      upcoming_interval: 2, 
      default_to_email: "", 
      default_subject: "",
      default_from_email: admin_user.email,
      default_sig: "Colin Wu",
      max_lines: 30,
      lines_per_page: 25,
      default_root_path: "/technicians",
      showbackup: false)
  end
  r.each do |row|
    team = Team.find_by_team_id(row.team_id)
    if team.nil?
      team = Team.create(:team_id => row.team_id, :name => row.region)
      if team.nil?
        puts "Problem creating team #{row.region}, #{row.team_id}"
        next
      end
    end
    if Technician.find_by_crm_id(row.crm_id).nil?
      row.email =~ /^([^@]+)@/
      sharpname = "sec\\" + $1
      t = team.technicians.create(:crm_id => row.crm_id, :first_name => row.first_name, :last_name => row.last_name, :friendly_name => row.friendly_name, :email => row.email, :car_stock_number => row.car_stock_number, :sharp_name => sharpname)
      if t.nil?
        puts "Problem creating technician:\n #{row.to_s}"
        next
      end
      t.create_preference(
        limit_to_region: true, 
        limit_to_territory: true, 
        default_notes: "#{t.friendly_name}'s notes ...", 
        upcoming_interval: 2, 
        default_to_email: "sharpdirectparts@sharpsec.com", 
        default_subject: "Parts transfer request from #{t.team.name}",
        default_from_email: t.email,
        default_sig: t.full_name,
        max_lines: 30,
        lines_per_page: 25,
        default_root_path: "/devices/my_pm_list",
        showbackup: false)
    end
  end
else
  puts "#{csv_file} does not exist."
end
