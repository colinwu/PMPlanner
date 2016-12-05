unless ARGC == 2
  puts "Syntax: import_prefs.rb preferences.csv technicians.csv"
  exit
end

csv_file = ARGV.shift
tech_csv = ARGV.shift

tech_lookup = Hash.new
if (File.exists?(csv_file))
  r = CsvMapper.import(csv_file) do 
    read_attributes_from_file
  end
  t = CsvMapper.import(tech_csv) do
    read_attributes_from_file
  end
  t.each do |row|
    tech_lookup[row.computername] = row.crm_resourceid
  end
  r.each do |row|
    crm_id = tech_lookup[row.computername]
    tech = Technician.find_by_crm_id(crm_id)
    unless tech.nil?
      tech.create_preference(
        :limit_to_region => row.limittoregion,
        :limit_to_territory => row.limittoterritory,
        :previous_pm => row.previouspm,
        :data_entry_date_prompt => row.dataentrydateprompt,
        :data_entry_notes_prompt => row.dataentrynotesprompt,
        :default_notes => row.defaulttechnotes,
        :select_territory => row.selectterritory,
        :territory_to_explore => row.territorytoexplore,
        :default_units_to_show => row.defaultunitstoshow,
        :upcoming_interval => row.upcominginterval,
        :use_default_email => row.useemaildefaults,
        :default_to_email => row.defaultemailp,
        :default_subject => row.defaultsubject,
        :default_from_email => row.defaultemaild,
        :default_message => row.defaultmessage,
        :default_sig => row.defaultsignature,
        :max_lines => row.maxlines,
        :email_edit => row.emailedit,
        :popup_equip_list => row.popupequipmentlist,
        :line_per_page => 25,
        :default_root_path => '/devices/my_pm_list'
        )
    end
  end
else
  puts "#{csv_file} does not exist."
end