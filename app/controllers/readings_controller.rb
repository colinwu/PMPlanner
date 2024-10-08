class ReadingsController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news

  def index
    @readings = Reading.order(:taken_at).page(params[:page]).per_page(lpp)
  end

  def show
    @reading = Reading.find(params[:id])
  end

  def new
    @reading = Reading.new
  end

  Sec = Struct.new(:line, :c_start, :len)

  def create
    msg = ""
    r_params = params['reading']

    # Check if there's a file being uploaded
    if (r_params['ptn1'].length > 0)
      r_params['ptn1'].each do |ptn1file|
        tmp_fh = ptn1file.tempfile
        seen = Hash.new
        line_number = 1
        content = Array.new
        idx = new_start = max_len = 0
        prev_section = ''
        ptn1_sec = Hash.new
        model = ''
        sn = ''
        codes = {}
        counter_column = {0 => 'COUNTER', 1 => 'TURN', 2 => 'DAY', 3 => 'LIFE', 4 => 'REMAIN'}
        section = {}
          # retrieve the file's date embedded as part of file name
        if ptn1file.original_filename =~ /_(\d+)_PTN/
          begin
            reading_date = Date.parse($1.slice(0,8))
          rescue
            msg += "#{$1.slice(0,8)} in the file name is not a valid date string. Defaulting to today. "
            current_user.logs.create(message: msg)
            flash[:alert] = msg
            reading_date = Date.today
          end
          @reading = Reading.new(technician_id: r_params['technician_id'], device_id: r_params['device_id'])
          # Read the contents of the file into the array 'content' and figure out the 
          # co-ordinates [line, start_column, length] of each SIM section. length is nil
          # means it is the last section horizontally; i.e. the section's data goes from
          # the start_column to the end of the line
          while (line = tmp_fh.gets)
            content << line
            # Get device's model and serial number
            unless (seen[:model])
              if (line =~ /MACHINE:\s+([A-Z0-9-]+)/)
                model = $1.gsub(/\W/,'')
                seen[:model] = true
              end
            end
            unless (seen[:sn])
              if (line =~ /S\/N: (\w+)/)
                sn = $1.slice(0,8)
                seen[:sn] = true
              end
            end
            # Find co-ordinates of the start of each section
            while (idx = line.index(/\(SIM(22-\d\d)/, new_start))
              sec_name = $1
              ptn1_sec[sec_name] = Sec.new(line_number, idx, 999)
              unless prev_section.length == 0
                ptn1_sec[prev_section].len = ptn1_sec[sec_name].c_start - ptn1_sec[prev_section].c_start
              end
              new_start = idx + 1
              prev_section = sec_name
            end
            idx = 0
            new_start = 0
            prev_section = ''
            line_number += 1
          end
          tmp_fh.close
      
          # finished locating sections of ptn1 file
          if (seen[:model] and seen[:sn])
            tmp_devlist = Device.joins(:model).where(["models.nm = ? and serial_number like ? and active = true", model, "#{sn}%"])
            unless tmp_devlist.empty?  # Is the ptn1 device in the db?
              ptn1_dev = tmp_devlist.first
              # if the reading dev is the template device then make the file device the reading device
              # @reading.update(device_id: ptn1_dev.id, taken_at: reading_date, notes: "Readings uploaded from #{ptn1file.original_filename} by #{@reading.technician.friendly_name}.")
            else # no...
              # This is what we used to do...
              # msg = "Device specified by PTN1 file is not for this device (PTN1: #{ptn1_dev.model.nm}, #{dev.serial_number})."
              # current_user.logs.create(device_id: @reading.device_id, message: msg)
              # redirect_to back_or_go_here(root_url), alert: msg
              # 
              # This is what we do now: go ahead and creat the device but giving it dummy crm_object_id,
              # client_id and location_id. This way techs can keep capturing counters until the device
              # gets added to CRM
              c = Client.find_by_name "Virtual Client"
              if c.nil?
                c = Client.create(name: "Virtual Client")
              end
              l = Location.find_by_city "Virtual Town"
              if l.nil?
                l = Location.create(
                  address1: "1 Virtual Rd", 
                  city: "Virtual Town", 
                  province: "ON", 
                  post_code: "A1B 2C3", 
                  notes: "For devices not yet registered in CRM", 
                  client_id: c.id
                  )
              end
              ptn1_dev = Device.create(
                crm_object_id: -1, 
                client_id: c.id,
                location_id: l.id,
                serial_number: sn,
                active: true,
                do_pm: true,
                pm_counter_type: 'counter',
                primary_tech_id: current_user.id,
                model_id: Model.find_by_nm(model).id
                )
              ptn1_dev.logs.create(message: "Device s/n #{sn} created by PTN1 file upload.")
            end
            @reading.update(device_id: ptn1_dev.id, taken_at: reading_date, notes: "Readings uploaded from #{ptn1file.original_filename} by #{@reading.technician.friendly_name}.")
            @reading.save
          else
            msg = "Couldn't figure out what device this PTN1 file is for. (#{ptn1file.original_filename})"
            current.user.logs.create(message: msg)
            redirect_to back_or_go_here(root_url), alert: msg
          end

          # if a reading for the same date already exists, delete it
          r = Reading.where(["id <> ? and taken_at = ? and device_id = ?", @reading.id, reading_date, @reading.device_id]).first
          unless r.nil?
            r.destroy
          end

          # generate list of PM codes for this model
          dev = @reading.device
          dev.model.model_group.model_targets.each do |c|
            unless (c.label.nil? or c.label.strip.empty?)
              codes[c.label] = c.maint_code
              section[c.maint_code] = c.section
            end
          end
            # if it's a colour model add the CTOTAL code
            # if dev.model.model_group.color_flag
            #   codes['TOTAL OUT(COL):'] = 'CTOTAL'
            #   section['CTOTAL'] = '22-01'
            # end
          # end
          codes.each do |label,name|
            new_label = label.gsub(/[()]/,{'(' => '\(',')' => '\)'})
            if ptn1_sec[section[name]].nil?
              dev.logs.create(message: "Don't know what section (#{label}, #{name}) is in.")
              next
            end
            line_idx = ptn1_sec[section[name]].line
            start_column = ptn1_sec[section[name]].c_start
            column_width = ptn1_sec[section[name]].len.nil? ? max_len : ptn1_sec[section[name]].len
            if name == 'PPF'
              ppf_max = 0
              while (row = content[line_idx][start_column, column_width] and not row =~ /^$/ and not row =~ /\(SIM/)
                if row =~ /#{new_label}\s+(\d+)/
                  ppf_max = (ppf_max < $1.to_i) ? $1.to_i : ppf_max
                end
                line_idx += 1
              end          
              counter = ppf_max
            else
              unit = 0
              begin
                row = content[line_idx][start_column, column_width]
                line_idx += 1
              end until (row =~ /#{new_label}\s*([-0-9]+)/ or row =~ /^$/ or row =~ /\(SIM/)
              counter = $1.to_i
              if (section[name] == '22-13')
                if (row =~ /#{new_label}\s*([-0-9]+)\s+([-0-9]+)\s+([-0-9]+)\s+([-0-9%]+)\s+([-0-9]+)/)
                  count_ary = [$1, $2, $3, $4, $5]
                  unit = count_ary[dev.pm_counter_type.to_i] == '--------' ? 0 : dev.pm_counter_type.to_i
                  counter = count_ary[unit].to_i
                end
              end
            end
            pm = PmCode.find_by name: name
            @reading.counters.find_or_create_by(pm_code_id: pm.id, value: counter, unit: unit, name: name)
          end # codes.each
        else # if ptn1file.original_filename pattern match
          msg = "Supplied file (#{ptn1file.original_filename}) is not a PTN1 file."
          current_user.logs.create(message: msg)
          redirect_to back_or_go_here(root_url), :alert => msg
        end
        
        msg += "PTN1 file for <a href='/devices/#{dev.id}/service_history'>#{dev.crm_object_id} (s/n: #{dev.serial_number})</a> processed.<br>"
        current_user.logs.create(device_id: dev.id, message: msg)
      end # for each r_params['ptn1']
      redirect_to back_or_go_here(@reading), notice: msg
    end
  end

  def edit
    @reading = Reading.find(params[:id])
  end

  def new_upload
    # This is where techs can upload PTN1 files without having to select a device first.
    you_are_here
    @reading = Reading.new(device_id: 1, technician_id: current_user.id)
  end

  def update
    @reading = Reading.find(params[:id])
    respond_to do |format|
      if @reading.update(reading_params)
        format.html {redirect_to @reading, notice: 'Successfully updated reading.'}
        format.json {respond_with_bip(@reading)}
      else
        format.html {render :action => 'edit', notice: 'Problem with data.'}
        format.json {respond_with_bip(@reading)}
      end
    end
  end

  def destroy
    @reading = Reading.find(params[:id])
    @reading.device.logs.create(technician_id: current_user.id, message: "Deleted counter data from #{@reading.taken_at}")
    @reading.destroy
    redirect_to back_or_go_here(readings_url)
  end
  private

  def reading_params
    params.require(:reading).permit(:taken_at, :notes, :device_id, :technician_id, :unit)
  end

end

