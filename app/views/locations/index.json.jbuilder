json.array!(@locations) do |loc|
  json.(loc, :id, :address1, :address2, :city, :province, :post_code, :team_id, :client_id, :to_s)
end
