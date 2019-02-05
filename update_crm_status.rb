Device.where("crm_active is NULL or crm_under_contract is NULL or crm_do_pm is NULL").each do |d|
  if d.crm_active.nil?
    d.crm_active = false
  end
  if d.crm_under_contract.nil?
    d.crm_under_contract = false
  end
  if d.crm_do_pm.nil?
    d.crm_do_pm = false
  end
  d.save
end