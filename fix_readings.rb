Reading.where("technician_id is not NULL and tech_name = ''").each do |r|
  r.update_attributes(tech_name: r.technician.full_name)
end

Reading.where("technician_id is NULL and tech_name = ''").each do |r|
  r.update_attributes(tech_name: r.device.primary_tech.full_name)
end