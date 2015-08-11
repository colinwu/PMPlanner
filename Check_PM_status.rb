Device.find_each do |dev|
  dev.update_pm_visit_tables
end # Device.all.each do |dev|
