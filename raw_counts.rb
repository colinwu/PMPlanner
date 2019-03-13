# Retrieve (and print) counter values for specified device and maint code.
# Maint code is specified as a string: BWTOTA:, DK, VK, etc
cnt_list = []
days_list = []
dev_id = ARGV.shift
code = ARGV.shift
dev = Device.find(dev_id)

day0 = dev.readings.order(:taken_at).first.taken_at
Device.find(dev_id).readings.order(:taken_at).each do |r|
  cnt_list << r.counter_for(code).value
  days_list << (r.taken_at - day0).to_i
end

puts cnt_list.to_s
puts days_list.to_s