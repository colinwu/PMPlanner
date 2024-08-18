Device.where(active: nil).each do |d|
  if (d.crm_object_id == '-1')
    d.update(active: true)
  else
    if (d.crm_active.nil?)
      puts "#{d.id} has crm ID #{d.crm_object_id}"
    else
      d.update(active: d.crm_active)
    end
  end
  d.update_pm_visit_tables
end