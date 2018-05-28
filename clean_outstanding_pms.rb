# Find all the OutstandingPm records that doesn't have a matching ModelTarget. If a counter
# doesn't exist for the model group, the corresponding OutstandingPm record should be delted.
# The common field is OutstandingPm.code and ModelTarget.maint_code

seen = {}

OutstandingPm.find_each do |op|  
  if op.device.nil?
    op.destroy
  else
    # next if op.code == 'BWTOTAL' or op.code == 'CTOTAL'
    mt = op.device.model.model_group.model_targets.find_by maint_code: op.code
    if mt.nil?
      if op.code == 'BWTOTAL'
        op.device.model.model_group.model_targets.create(maint_code: 'BWTOTAL', target: 0)
        Log.create(device: op.device, message: "BWTOTAL target was missing - created.")
      end
      Log.create(device: op.device, message: "OutstandingPm for #{op.code} removed.")
      puts "#{op.device.crm_object_id}: OutstandingPm for #{op.code} removed."
      op.destroy
      # mg = op.device.model.model_group
      # mg.models.includes(:devices).each do |m|
      #   unless seen[m.id]
      #     puts "#{m.nm} does not have Maint Code #{op.code}"
      #     puts "These devices have OutstandingPm records for #{op.code}:"    
      #     m.devices.each do |d|
      #       puts d.crm_object_id
      #     end
      #     seen[m.id] = 1
      #   end
      # end
    end
  end
end