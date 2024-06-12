csv_file = ARGV.shift
today = Time.now().midnight

if File.exists?(csv_file)
  r = CsvMapper.import(csv_file) do
    start_at_row 1
    [model_name]
  end

  r.each do |row|
    dm = Model.find_by_nm(row.model_name)
    unless (dm.nil?)
      dlist = Device.where("model_id = #{dm.id}")
      unless dlist.length == 0
        dlist.destroy_all()
        # dlist.each do |d|
        #   d.destroy
        # end
      else
        puts "There were no #{dm.nm} devices in the database."
      end
    else
      puts "We don't have that model in the database."
    end
  end
else
  puts "Can't find or open #{csv_file}"
end
