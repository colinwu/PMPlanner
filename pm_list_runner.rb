Log.create(technician_id: 1, message: "Starting pm_list_runner.rb")
dow_today = Date.today.to_fs(:dow_num).to_i

Technician.where("team_id <> 61000184").find_each do |tech|
  send = false
  if (tech.preference.pm_list_freq > 0)   # maybe we have to send something
    # calculate next send date
    if (tech.preference.pm_list_freq < 7) # looking for a week day
      if (tech.preference.pm_list_freq_unit == dow_today)  # right day of week
        if ((tech.sent_date.nil?) or ((tech.sent_date + tech.preference.pm_list_freq * 7) == Date.today))
          send = true
        end
      end
    elsif (tech.preference.pm_list_freq == 7)        
      # is today the 1st of the month?
      if (Date.today.day == 1)
        send = true
      end
    else
      tech.logs.create(message: "unknown pm_list delivery frequency")
    end
  end

  if (send)
    tech.logs.create(message: "Sending PM list")
    TechMailer.pm_list(tech).deliver_later
  end
end
