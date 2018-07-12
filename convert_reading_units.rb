Device.find_each do |d|
  if d.pm_counter_type == 'counter'
    d.pm_counter_type = '0'
  elsif d.pm_counter_type == 'rotration'
    d.pm_counter_type = '1'
  elsif d.pm_counter_type == 'life'
    d.pm_counter_type = '3'
  end
  d.save
end

Counter.find_each do |c|
  if c.unit == 'count' or c.unit == 'counter'
    c.unit = '0'
  end
  c.save
end