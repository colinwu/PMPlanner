combo = {}
PartsForPm.where("choice = 4").each do |pfp|
  if combo[pfp.part_id].nil?
    combo[pfp.part_id] = [PmCode.find(pfp.pm_code_id).name]
  else
    combo[pfp.part_id] << PmCode.find(pfp.pm_code_id).name
  end
end

combo.each do |part, code|
  uniq_codes = code.uniq
  next if uniq_codes.length == 1
  puts Part.find(part).name + ": " + uniq_codes.inspect
end