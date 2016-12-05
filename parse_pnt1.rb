seen = {date: false, model: false, sn: false}
codes = {'TOTAL OUT\(BW\):' => 'BWTOTAL', 'TOTAL OUT\(COL\):' => 'CTOTAL'}
counter_column = {0 => 'COUNTER', 1 => 'TURN', 2 => 'DAY', 3 => 'LIFE', 4 => 'REMAIN'}
section = Hash.new
counter = Hash.new
turn = Hash.new
day = Hash.new
life = Hash.new
remain = Hash.new
dev = Device.new
file = ARGV.shift
file =~ /_(\d{4,4})(\d{2,2})(\d{2,2})\d{4,4}_PTN/
year = $1
month = $2
dom = $3
f = File.open(file)
while (row = f.gets)
# Seems the date contained within the file is not in a consistent format so must rely
# on the file name instead.
#  
#   unless (seen[:date])
#     if (row =~ /([A-Za-z]{3,3})\/(\d\d)\/(\d{4,4})/)
#       month = $1
#       day = $2
#       year = $3
#       seen[:date] = true
#     end
#   end
  unless (seen[:model])
    if (row =~ /MACHINE:\s+([A-Z0-9-]+)/)
      model = $1
      seen[:model] = true
    end
  end
  unless (seen[:sn])
    if (row =~ /S\/N: (\w+)/)
      sn = $1
      seen[:sn] = true
    end
  end
  if (seen[:model] and seen[:sn])
#     dev = Device.joins(:model).where(["models.name = ? and serial_number = ?", model, sn]).first
    dev = Device.joins(:model).where(["models.name = ?", model]).first
    if dev.nil?
      puts "Device not found."
      exit
    else
      dev.pm_codes.each do |c|
        unless c.label.nil?
          codes[c.label] = c.name
          section[c.name] = c.section
        end
      end
    end
  end
  unless dev.nil?
    codes.each do |label,name|
      unless (seen[name])
        if (section[name] == '22-13')
          if (row =~ /#{label}\s+([-0-9]+)\s+([-0-9]+)\s+([-0-9]+)\s+([-0-9]+)%\s+([-0-9]+)/)
            counter[name] = $1.to_i
            turn[name] = $2.to_i
            day[name] = $3.to_i
            life[name] = $4.to_i
            remain[name] = $5.to_i
            seen[name] = true
          end
        else
          if (row =~ /#{label}\s+(\d+)/)
            counter[name] = $1.to_i
            seen[name] = true
          end
        end
      end
    end
  end
end

puts "Date = #{month} #{dom}, #{year}"
puts "Model = #{model}, SN = #{sn}\n"
codes.each do |label, name|
  puts "#{name}: #{counter[name]}"
end
