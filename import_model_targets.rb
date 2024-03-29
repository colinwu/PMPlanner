# Check prerequisite: ModelGroup must have been populated already
if ModelGroup.all.size == 0
  puts "The ModelGroup table must be populated first. Run import_model_group.rb."
  exit
end

csv_file = ARGV.shift
if (File.exists?(csv_file))
  r = CsvMapper.import(csv_file) do 
    start_at_row 1
    [groupname,groupdescription,groupcolor,amv,counterkey,mreq,ta,ca,aa,drc,dvc,dk,dc,dm,dy,vk,vc,vm,vy,tk,tk1,tk2,tk3,fk,fk1,fk2,fk3,spf,ppf,ink,wst,othr]
  end
  
  target_names = %w[amv mreq ta ca aa drc dvc dk dc dm dy vk vc vm vy tk tk1 tk2 tk3 fk fk1 fk2 fk3 spf ppf ink wst othr]
  r.each do |row|
    color_flag = (row.groupcolor == 'FALSE') ? false : true
    m = ModelGroup.find_by_name row.groupname
    unless m.nil?
      m.description = row.groupdescription
      m.color_flag = color_flag
      m.save
    else
      puts "Created new group #{row.groupname}"
      m = ModelGroup.create(:name => row.groupname, :description => row.groupdescription, :color_flag => color_flag)
    end
    m.model_targets.find_or_create_by(target: 0, maint_code: 'BWTOTAL', unit: 'count')
    if m.color_flag
      m.model_targets.find_or_create_by(target: 0, maint_code: 'CTOTAL', unit: 'count')
    end
    target_names.each do |t|
      next if row[t].nil? or row[t] == '0'
      found_target = false
      # See if there are any targets already associated with this model
      unless m.model_targets.empty?
        # If yes, are any of them the one we're looking for
        model_target = m.model_targets.find_by(maint_code: t)
        unless model_target.nil?
          found_target = true
        end
      end
      if (found_target == false)
        rt = m.model_targets.create(:target => row[t], :maint_code => t.upcase, :unit => 'count')
        puts "Create new target for model group #{m.name}, code #{t}, value #{row[t]}"
      else
        model_target.target = row[t] # update the target value
        if model_target.save
          puts "Updated target for model group #{m.name}, code #{t}, value #{row[t]}"
        else
          puts "Error saving target for model group #{m.name}, code #{t}, value #{row[t]}"
        end
      end
    end
  end
else
  puts "#{csv_file} does not exist or can not be opened."
end
