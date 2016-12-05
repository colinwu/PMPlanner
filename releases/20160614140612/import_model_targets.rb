# Check prerequisite: ModelGroup must have been populated already
if ModelGroup.all.size == 0
  puts "The ModelGroup table must be populated first. Run import_model_group.rb."
  exit
end

csv_file = ARGV.shift
if (File.exists?(csv_file))
  r = CsvMapper.import(csv_file) do 
    start_at_row 1
    [groupname,groupdescription,groupcolor,amv,counterkey,mreq,ta,ca,aa,drc,dvc,dk,dc,dm,dy,vk,vc,vm,vy,tk,tk1,tk2,fl,fk1,fk2,fk3,spf,ppf,ink,wst,othr]
  end
  
  target_names = %w[amv counterkey mreq ta ca aa drc dvc dk dc dm dy vk vc vm vy tk tk1 tk2 fl fk1 fk2 fk3 spf ppf ink wst othr]
  r.each do |row|
    color_flag = (row.groupcolor == '=FALSE()') ? false : true
    m = ModelGroup.find_by_name row.groupname
    unless m.nil?
      m.description = row.groupdescription
      m.color_flag = color_flag
      m.save
    else
      m = ModelGroup.create(:name => row.groupname, :description => row.groupdescription, :color_flag => color_flag)
    end
    model_target = ModelTarget.new
    target_names.each do |t|
      next if row[t].nil?
      found_target = false
      # See if there are any targets already associated with this model
      unless m.model_targets.empty?
        # If yes, are any of them the one we're looking for
        m.model_targets.each do |rt|
          if rt.maint_code == t
            model_target = rt
            found_target = true
            break;
          end
        end
      end
      if (found_target == false)
        rt = m.model_targets.create(:target => row[t], :maint_code => t, :unit => 'count')
      else
        model_target.target = row[t] # update the target value
        model_target.save
      end
    end
  end
else
  puts "#{csv_file} does not exist or can not be opened."
end
