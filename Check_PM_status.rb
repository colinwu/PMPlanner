Reading.where("taken_at is NULL").each {|r| r.destroy}
Device.find_each do |dev|
  dev.update_pm_visit_tables
end # Device.all.each do |dev|
