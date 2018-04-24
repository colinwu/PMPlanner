ptn1 = ARGV.shift
f = File.open(ptn1)
Sec = Struct.new(:line, :c_start, :len)
line_number = 1
content = Array.new
idx = 0
new_start = 0
prev_section = ''
section = Hash.new

while (line = f.gets)
  content << line
  while (idx = line.index(/\(SIM(22-\d\d)/, new_start))
    sec_name = $1
    puts "Found #{sec_name} at line #{line_number}"
    section[sec_name] = Sec.new(line_number, idx, 999)
    unless prev_section.length == 0
      section[prev_section].len = section[sec_name].c_start - section[prev_section].c_start
    end
    new_start = idx + 1
    prev_section = sec_name
  end
  idx = 0
  new_start = 0
  prev_section = ''
  line_number += 1
end
f.close

puts ("There were #{line_number} lines in the file.")
sec_name = '22-09'
line_idx = section[sec_name].line
start_column = section[sec_name].c_start
column_width = section[sec_name].len.nil? ? max_len : section[sec_name].len

ppf_max = 0
label = 'TRAY\d:'
while (row = content[line_idx][start_column, column_width] and not row =~ /^$/ and not row =~ /\(SIM/)
  if row =~ /#{label}\s+(\d+)/
    ppf_max = (ppf_max < $1.to_i) ? $1.to_i : ppf_max
  end
  line_idx += 1
end
puts ("PPF = #{ppf_max}")