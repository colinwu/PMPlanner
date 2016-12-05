seen = Hash.new
Client.all.each do |c|
  if seen[c.name].nil?
    c.sold_tos.create(sold_to_id: c.soldtoid)
    seen[c.name] = c.id
  else
    prev_client = Client.find(seen[c.name])
    prev_client.sold_tos.create(sold_to_id: c.soldtoid)
    c.destroy
  end
end