Device.where("length(serial_number) = 7").each do |d|
  d.update!(serial_number: "0#{d.serial_number}")
end