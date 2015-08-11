seen = Hash.new
Location.all.each do |location|
  loc = [location.address1,location.address2,location.city,location.province,location.post_code,location.client_id].join(':')
  if seen[loc].nil?
    location.ship_tos.create(client_id: location.client_id, ship_to_id: location.shiptoid)
    seen[loc] = location.id
  else
    prev_loc = Location.find(seen[loc])
    puts "Loc ID #{location.id}: Previous Location: #{prev_loc.id}"
    prev_loc.ship_tos.create(client_id: location.client_id, ship_to_id: location.shiptoid)
    location.devices.each do |d|
      puts "Device #{d.id} location switched"
      d.location = prev_loc
      d.save
    end
    location.destroy
  end
end