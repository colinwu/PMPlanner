Log.create(technician_id: 1, message: "Starting Check_PM_status")
Reading.where("taken_at is NULL").each {|r| r.destroy}
Device.find_each do |dev|
  begin
    dev.update_pm_visit_tables
  rescue
    Log.create(technician_id: 1, device_id: dev.id, message: "Could not update Outstanding PM table")
  end
end # Device.all.each do |dev|
Log.create(technician_id: 1, message: "Finished Check_PM_status")
