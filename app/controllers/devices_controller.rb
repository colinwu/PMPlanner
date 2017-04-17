class DevicesController < ApplicationController
  before_action :authorize
  before_action :require_manager, only: [:new, :create, :destroy, :send_transfer]
  helper_method :sort_column, :sort_direction
  autocomplete :client, :name, full: true
  
  def index
    you_are_here
    @search_params = params[:search] || Hash.new
    search_ar = ['placeholder']
    where_ar = []
    if params[:search]
      unless @search_params['crm'].nil? or @search_params['crm'].blank?
        search_ar <<  @search_params[:crm]
        where_ar << "crm_object_id regexp ?"
      end
      unless  @search_params['model'].nil? or  @search_params['model'].blank?
        search_ar <<  @search_params[:model]
        where_ar << "models.nm regexp ?"
      end
      unless  @search_params['sn'].nil? or  @search_params['sn'].blank?
        search_ar <<  @search_params[:sn]
        where_ar << "serial_number regexp ?"
      end
      unless  @search_params['client_name'].nil? or  @search_params['client_name'].blank?
        search_ar <<  @search_params['client_name']
        where_ar << "clients.name regexp ?"
      end
      unless  @search_params['addr1'].nil? or  @search_params['addr1'].blank?
        search_ar <<  @search_params['addr1']
        where_ar << "locations.address1 regexp ?"
      end
      unless  @search_params['city'].nil? or  @search_params['city'].blank?
        search_ar <<  @search_params['city']
        where_ar << "locations.city regexp ?"
      end
      search_ar[0] = where_ar.join(' and ')
    else
      search_ar = []
    end
    if params[:sort].nil? or params[:sort].empty?
      @order = 'crm_object_id'
    else
      @order = sort_column + ' ' + sort_direction
    end
    # an empty current_technician means we're not working with any specific tech
    if current_technician.nil?
      if current_user.admin?
        @title = "All Devices"
        @devices = Device.joins(:location, :client,:model).where(search_ar).order(@order).page(params[:page])
      elsif current_user.manager?
        @title = "Devices in #{current_user.team.name}"
        @tech = current_user
        unless where_ar.empty?
          search_ar[0] = [search_ar[0], 'devices.team_id = ?'].join(' and ')
          search_ar << current_user.team_id
        else
          search_ar = ["devices.team_id = ?", current_user.team_id]
        end
        @devices = Device.joins(:location,:client,:model).where(search_ar).order(@order).page(params[:page])
      else
# should never reach this
#         @title = "My Territory"
#         @tech = current_user
      end
    else
      @title = "#{current_technician.friendly_name}'s Devices"
      @tech = current_technician
      unless where_ar.empty?
        search_ar[0] = [search_ar[0], 'primary_tech_id = ?'].join(' and ')
        search_ar << @tech.id
      else
        search_ar = ["primary_tech_id = ?", @tech.id]
      end
      @devices = Device.joins(:location,:client,:model).where(search_ar).order(@order).page(params[:page])
    end
    
    if @devices.nil? or @devices.empty?
      @devices = @tech.primary_devices.joins(:location, :client, :model).where(search_ar).order(@order).page(params[:page])
    end
  end

  def show
    @device = Device.find(params[:id])
    if current_user.can_manage?(@device)
      you_are_here
      @manager = Technician.where(["team_id = ? and manager = TRUE", @device.team_id]).first
      @contacts = @device.location.contacts
    else
      flash[:alert] = "You are not allowed to access that device."
      redirect_to back_or_go_here
    end
  end

  def new
    @title = "Add a new device"
    session[:caller] = request.path_parameters[:action]
    you_are_here
    @device = Device.new(pm_counter_type: 'count', active: true, do_pm: true)
# only admin or manager can add devices
    if current_user.admin? or current_user.manager?
      @all_dev_ids = Device.all.map { |d| "#{d.crm_object_id}" }
      @device.team_id = current_technician.team_id || Team.find_by(name: 'Admin').id
      @readonly_flag = false
      @contacts = []
      @locations = []
    else
      redirect_to back_or_go_here, :alert => "You are not allowed to add devices. Pease see your manager."
    end
  end

  def create
    @device = Device.new(params[:device])
    if params[:device][:model_id].empty?
      flash[:alert] = "The model you specified is not known to PM Planner. Please make sure it is in the system before proceeding."
      render action: 'new'
      return
    end
    if @device.team.nil?
      team = Team.find_by_name(params[:team])
      @device.team_id = team.id
    end
    unless params[:location][:address1].empty?
      loc = Location.find_or_create_by(params[:location])
      loc.team_id = @device.team_id
      loc.client_id = params[:device][:client_id]
      loc.save
      params[:device][:location_id] = loc.id
    end
      
    if @device.update_attributes(params[:device])
      current_user.logs.create(device_id: @device.id, message: "Created device record with #{params[:device].inspect}")
      flash[:alert] = nil
      flash[:error] = nil
      flash[:notice] = "Successfully created device record."
      redirect_to back_or_go_here(edit_device_url(@device))
    else
      @locations = Location.where(["client_id = ? and team_id = ?", @device.client_id, @device.team_id])
      @contacts = @device.location.contacts
      if current_user.can_manage?(@device)
        you_are_here
        @readonly_flag =  true
      else
        @readonly_flag =  false
        flash[:alert] = "You are only allowed to edit some settings."
      end
      render :action => 'new'
    end
  end

  def edit
    @title = "Edit device info"
    session[:caller] = request.path_parameters[:action]
    you_are_here
    @device = Device.find(params[:id])
    @locations = Location.where(["client_id = ? and team_id = ?", @device.client_id, @device.team_id])
    @contacts = @device.location.contacts
    if current_user.can_manage?(@device)
      @readonly_flag =  false
    else
      @readonly_flag =  true
      flash[:alert] = "You are only allowed to edit some settings."
    end
  end

  def update
    @device = Device.find(params[:id])
    unless params[:location][:address1].empty?
      loc = Location.find_or_create_by(params[:location])
      loc.team_id = @device.team_id
      loc.client_id = params[:device][:client_id]
      loc.save
      params[:device][:location_id] = loc.id
    end
    if @device.update_attributes(params[:device])
      current_user.logs.create(device_id: @device.id, message: "Updated device with #{params[:device].inspect}")
      flash[:alert] = nil
      flash[:error] = nil
      flash[:notice] = "Successfully updated device."
      redirect_to back_or_go_here(edit_device_url(@device))
    else
      @locations = Location.where(["client_id = ? and team_id = ?", @device.client_id, @device.team_id])
      @contacts = @device.location.contacts
      if current_user.can_manage?(@device)
        @readonly_flag =  true
      else
        @readonly_flag =  false
        flash[:alert] = "You are only allowed to edit some settings."
      end
      render :action => 'edit'
    end
  end

  def destroy
    @device = Device.find(params[:id])
    if current_user.can_manage?(@device)
      @device.destroy
      flash[:notice] = "Successfully removed device record."
      current_user.logs.create(device_id: @device.id, message: "Deleted device")
    else
      current_user.logs.create(device_id: @device.id, message: "Not authorized to delete device")
      flash[:alert] = "Only admin or managers can delete devices."
    end
    redirect_to devices_url
  end
  
  def rm_contact
    contact_id = params['contact']
    dev = Device.find(params['dev']) 
    dev.location.contacts.delete(contact_id)
    current_user.logs.create(device_id: dev.id, message: "contact #{contact_id} no longer associated with device")
    redirect_to back_or_go_here
  end
  
  def add_contact_for
    @device = Device.find(params[:id])
    contact_param = params[:contact]
    @contact = Contact.where(["name = ? or email = ?", contact_param[:name], contact_param[:email]]).first
    if @contact.nil?
      @contact = @device.location.contacts.create(contact_param)
      current_user.logs.create(device_id: @device.id, message: "New contact #{@contact.id} created and associated with device.")
    else
      @device.location.contacts << @contact
      current_user.logs.create(device_id: @device.id, message: "Contact #{@contact.id} associated with the device.")
    end
    redirect_to back_or_go_here
  end
  
  def enter_data
    session[:search_caller] = request.path_parameters[:action]
    you_are_here
    
    @bw_list = []
    @c_list = []
    @all_list = []
    @now = Date.today
    @title = "Enter Counter Data"
    begin
      @device = Device.find(params[:id])
    rescue
      @device = nil
    end
    if @device and current_user.can_manage?(@device)
      @reading = @device.readings.build(technician_id: current_user.id)
      @device.pm_codes.each do |code|
        if code.colorclass == 'BW'
          @bw_list << code.name
        elsif code.colorclass == 'COLOR'
          @c_list << code.name
        elsif code.colorclass == 'ALL'
          @all_list << code.name
        end
      end
      if @device.device_stat.nil?
        stats = @device.calculate_stats
      else
        stats = @device.device_stat
      end
      @bw_monthly = stats['bw_monthly']
      @c_monthly = stats['c_monthly']
      @vpy = stats['vpy']
      @last_reading = @device.last_non_zero_reading_on_or_before(@now)
#       @last_reading = @device.readings.where("taken_at < '#{@now}'").order(:taken_at).last
      if @last_reading.nil?
        @last_reading = Reading.new(taken_at: Date.today)
        @lastbw = 0
        @lastc = 0
      else
        @lastbw = @last_reading.counter_for('bwtotal').value
        @lastc = 0
        if (@device.model.model_group.color_flag)
          @lastc = @last_reading.counter_for('ctotal').value
        end
      end
      
      @reading = @device.readings.build(technician_id: current_user.id, taken_at: Date.today, notes: current_user.preference.default_notes)
      @codes = @device.model.model_group.model_targets.where("maint_code <> 'AMV'").map(&:maint_code)
    else
      @device = nil
      flash[:alert] = "No valid device specified."
    end
  end
  
  def record_data
#     TODO: Should do some value sanity checking here
    @device = Device.find(params[:id])
    @reading = @device.readings.find_or_create_by(taken_at: params[:reading][:taken_at])
    @reading.update_attributes(params[:reading])
    params[:counter].each do |code,value|
      p = PmCode.find_by_name(code)
      begin
        v = value.gsub(/[^0-9-]/,'')
        c = @reading.counters.find_or_create_by(pm_code_id: p.id)
        c.update_attributes(value: v, unit: 'count')
      rescue
        flash[:alert] += "Error saving counter for #{p.name}. Value = #{v}"
        current_user.logs.create(device_id: @device.id, message: "Error saving counter for #{p.name}. Value = #{value}")
      end
    end
    current_user.logs.create(device_id: @device.id, message: "Counter data saved.")
    @device.update_pm_visit_tables
    redirect_to analyze_data_device_url(@device)
  end
  
  def analyze_data
    session[:search_caller] = request.path_parameters[:action]
    you_are_here
    @rows = Array.new
    @now = Date.today
    @bw_list = []
    @c_list = []
    @all_list = []
    @title = "Analysis and Estimate"
    
    begin
      @device = Device.find(params[:id])
    rescue
      @device = nil
    end
    unless current_technician.nil?
      @tech = current_technician
    else
      @tech = @device.primary_tech
    end
    if @device and current_user.can_manage?(@device)
      @reading = @device.readings.build(technician_id: current_user.id)
      @device.pm_codes.each do |code|
        if code.colorclass == 'BW'
          @bw_list << code.name
        elsif code.colorclass == 'COLOR'
          @c_list << code.name
        elsif code.colorclass == 'ALL'
          @all_list << code.name
        end
      end
      if @device.device_stat.nil?
        avg = @device.calculate_stats
        @device.create_device_stat(c_monthly: avg['c_monthly'], bw_monthly: avg['bw_monthly'], vpy: avg['vpy'])
      else
        avg = @device.device_stat
      end
      @bw_monthly = avg['bw_monthly']
      @c_monthly = avg['c_monthly']
      @vpy = avg['vpy']
      
      @todays_reading = @device.readings.find_by_taken_at(@now)
      @prev_reading = @device.last_non_zero_reading_on_or_before(@now-1)
      
      unless @prev_reading.nil?
        last_now_interval = @now - @prev_reading.taken_at
        range = @tech.preference.upcoming_interval * 7
        dailyc = 0
        if @device.model.model_group.color_flag
          dailyc = @c_monthly / 30.5
          last_c_val = @prev_reading.counter_for('ctotal').value
          c_estimate = @todays_reading.nil? ? (last_c_val + dailyc * last_now_interval) : @todays_reading.counter_for('ctotal').value
        end
      
        # Calculate BW stats
        dailybw = @bw_monthly / 30.5
        last_bw_val = @prev_reading.counter_for('bwtotal').value
        bw_estimate = @todays_reading.nil? ? (last_bw_val + (dailybw + dailyc) * last_now_interval) : @todays_reading.counter_for('bwtotal').value
        
        # BW and C progress % and PM Dates depend on @vpy
        visit_interval = 365 / @vpy
        prog = 100.0 * last_now_interval / visit_interval
        next_pm_date = @todays_reading.nil? ? (@prev_reading.taken_at + visit_interval.round) : (@todays_reading.taken_at + visit_interval)
        
        # background color for the total counters
        case
        when next_pm_date <= @now
          bgclass = 'emerg'
        when (next_pm_date < @now + range) # (> @now is implied)
          bgclass = 'urgent'
        when (next_pm_date < @now + 2*range)
          bgclass = 'approaching'
        else
          bgclass = ''
        end
        
        # Record TotBW row
        @rows << [bgclass,
                'BWTOTAL',
                'Total Counter: BW',
                last_bw_val,
                @bw_monthly != 0 ? bw_estimate.round : 0,
                @bw_monthly != 0 ? prog : 0,
                @bw_monthly != 0 ? next_pm_date.strftime("%b %-d, %Y") : '']
        
        if @device.model.model_group.color_flag
        # Record TotC row if there's any
          @rows << [bgclass,
                  'CTOTAL',
                  'Total Counter: Color',
                  last_c_val,
                  @c_monthly != 0 ? c_estimate.round : 0,
                  @c_monthly != 0 ? prog : 0,
                  @c_monthly != 0 ? next_pm_date.strftime("%b %-d, %Y") : '']
        end
        
        # Now calculate stuff for all the other PM codes
        @codes_list = @device.model.model_group.model_targets.where("maint_code <> 'AMV'").map(&:maint_code)
        critical_codes_list = Array.new
        @choices = Hash.new
        
        @codes_list.each do |c|
          @choices[c] = 0
          target = @device.target_for(c)
          unless target.nil? or target.target == 0
            pm_code = PmCode.where(["name = ?", c]).first
            target_val = target.target
            last_val = @prev_reading.counter_for(c).nil? ? 0 : @prev_reading.counter_for(c).value
            if pm_code.colorclass == 'ALL'
              daily = dailyc + dailybw
            elsif pm_code.colorclass == 'COLOR'
              daily = dailyc
            elsif pm_code.colorclass == 'BW'
              daily = dailybw
            end
            monthlyaverage = daily * 30.5
            estimate = @todays_reading.nil? ? (last_val + daily * last_now_interval) : @todays_reading.counter_for(c).value
            prog = (100.0 * estimate / target_val)
            case monthlyaverage
            when 0
              next_pm_date = @now + 366
            else
              next_pm_date = (@now + (30.5*(target_val - estimate) / monthlyaverage))
            end
            # CSS class 
            range = @tech.preference.upcoming_interval * 7
            # set background color and also remember the ones that are either 'emerg' or 'urgent' state
            case
            when next_pm_date <= @now
              bgclass = 'emerg'
              critical_codes_list << c unless (c == 'TA' or c == 'CA')
            when (next_pm_date < @now + range) # (> @now is implied)
              bgclass = 'urgent'
              critical_codes_list << c unless (c == 'TA' or c == 'CA')
            when (next_pm_date < @now + 2*range)
              bgclass = 'approaching'
            else
              bgclass = ''
            end
            
            case
            when next_pm_date > @now + 365
              npd = "> 1 year away"
            else
              npd = next_pm_date.strftime("%b %-d, %Y")
            end
            @rows << [bgclass,
                      c,
                      pm_code.description, 
                      last_val, 
                      @bw_monthly != 0 ? estimate.round : 0, 
                      @bw_monthly != 0 ? prog : 0,
                      npd]
          end # unless target.nil? or target.target == 0
        end # codes_list.each do |c|
        @critical_codes = critical_codes_list.join(',')
      else
        flash[:alert] = "Can not perform analysis: Insufficient data."
        redirect_to enter_data_device_path(@device)
      end
    else
      flash[:alert] = "No valid, device specified."
      @device = nil
    end
  end
  
  def service_history
    session[:search_caller] = request.path_parameters[:action]
    you_are_here
    
    begin
      @device = Device.find(params[:id])
    rescue
      @device = nil
    end
    @title = "Service History"
    if @device.nil?
      flash[:alert] = "No valid device specified."
      render "service_history"
      return
    end
    
    if @device and current_technician.can_manage?(@device)      
      @reading = @device.readings.build(technician_id: current_technician.id)
      @last_reading = @device.readings.order(:taken_at).last
      
      if @device.device_stat.nil?
        stats = @device.calculate_stats
        @device.create_device_stat(c_monthly: stats['c_monthly'], bw_monthly: stats['bw_monthly'], vpy: stats['vpy'])
      else
        stats = @device.device_stat
      end
        
      @bw_monthly = stats['bw_monthly']
      @c_monthly = stats['c_monthly']
      @vpy = stats['vpy']
      
      @readings = @device.readings.order(taken_at: :desc)
      @all_codes = @device.model.model_group.model_targets.map do |t|
        if !t.target.nil? and t.target > 0
          t.maint_code
        end
      end
      @all_codes.delete(nil)
      @all_codes.delete('AMV')
    else
      flash[:alert] = "No valid device specified."
    end
  end
  
  def my_pm_list
    you_are_here
    @search_params = params[:search] || Hash.new
    if params[:showbackup].nil?
      @showbackup = current_user.preference.showbackup.to_s
    else
      if params[:showbackup] == 'true'
        @showbackup = "true"
      else
        @showbackup = "false"
      end
    end
    if current_technician.nil?
      if (current_user.admin?)
        my_team = Technician.all
        @title = "PM List for all devices"
      elsif current_user.manager?
        my_team = Technician.where(["team_id = ?",current_user.team_id])
        @title = "PM List #{current_user}.team.name"
      end
    else
      my_team = [current_technician]
      @title = ""
    end
    @now = Date.today
    @dev_list = []
    unless params[:sort].nil?
      @order = sort_column + ' ' + sort_direction
    else
      @order = 'locations.address1'
    end
    my_team.each do |tech|
      range = tech.preference.upcoming_interval*7
      
      # toggle to show devices for which the current tech is the backup tech
      if @showbackup == "true"
        where_ar = ["(primary_tech_id = ? or backup_tech_id = ?) and active is true and under_contract is true and do_pm is true"]
        search_ar = ["",tech.id, tech.id]
      else
        where_ar = ["primary_tech_id = ? and active is true and under_contract is true and do_pm is true"]
        search_ar = ["", tech.id]
      end
      
      # Build condition based on search fields
      if params[:search]
        unless @search_params['crm'].nil? or @search_params['crm'].blank?
          search_ar <<  @search_params[:crm]
          where_ar << "crm_object_id regexp ?"
        end
        unless  @search_params['model'].nil? or  @search_params['model'].blank?
          search_ar <<  @search_params[:model]
          where_ar << "models.nm regexp ?"
        end
        unless  @search_params['sn'].nil? or  @search_params['sn'].blank?
          search_ar <<  @search_params[:sn]
          where_ar << "serial_number regexp ?"
        end
        unless  @search_params['client_name'].nil? or  @search_params['client_name'].blank?
          search_ar <<  @search_params['client_name']
          where_ar << "clients.name regexp ?"
        end
        unless  @search_params['addr1'].nil? or  @search_params['addr1'].blank?
          search_ar <<  @search_params['addr1']
          where_ar << "locations.address1 regexp ?"
        end
        unless  @search_params['city'].nil? or  @search_params['city'].blank?
          search_ar <<  @search_params['city']
          where_ar << "locations.city regexp ?"
        end
      end
      search_ar[0] = where_ar.join(' and ')
      
      if (sort_column == 'outstanding_pms')
        code_count = {}
        sorted_count = []
        devs = Device.where(search_ar).joins(:location, :client, :model)
        devs.each do |d| 
          if d.active and d.under_contract and d.do_pm
            if !d.outstanding_pms.empty? or (!d.neglected.nil? and (d.neglected.next_visit < (@now + range*2)))
              code_count[d.id] = d.outstanding_pms.count
            end
          end
        end
        sorted_count = code_count.sort_by { |k,v| v }
        if (sort_direction == 'desc')
          sorted_count.reverse!
        end
        sorted_count.each do |c|
          @dev_list << devs.find(c[0])
        end
      else
        Device.includes(:primary_tech, :outstanding_pms, :client, :model, :location).where(search_ar).order(@order).references(:clients, :models, :locations).each do |dev|
#           if dev.active and dev.under_contract and dev.do_pm
            if !dev.outstanding_pms.empty? or (!dev.neglected.nil? and (dev.neglected.next_visit < (@now + range*2)))
              @dev_list << dev
            end # if
#           end # if
        end # Device.each
      end
    end
  end
  
  # This action handles searching from the "Analysis", "Data Entry" and "History" screens.
  def search
    @search_params = {}
    if params[:commit] == 'Search' and not params[:search_str].blank?
      @search_str = params[:search_str]
      @title = "Search: #{@search_str}"
      if current_user.admin?
        @devices = Device.joins(:model, :client, :location, :primary_tech).where(["crm_object_id regexp ? or serial_number regexp ? or models.nm regexp ? or clients.name regexp ? or locations.address1 regexp ? or technicians.first_name regexp ? or technicians.last_name regexp ? or technicians.friendly_name regexp ?", @search_str, @search_str, @search_str, @search_str, @search_str, @search_str, @search_str, @search_str]).order(:crm_object_id).page(params[:page])
      elsif current_user.manager?
        @devices = Device.joins(:model, :client, :location, :primary_tech).where(["(crm_object_id regexp ? or serial_number regexp ? or models.nm regexp ? or clients.name regexp ? or locations.address1 regexp ? or technicians.first_name regexp ? or technicians.last_name regexp ? or technicians.friendly_name regexp ?) and devices.team_id = ?", @search_str, @search_str, @search_str, @search_str, @search_str, @search_str, @search_str, @search_str, current_technician.team_id]).order(:crm_object_id).page(params[:page])
      else
        @devices = Device.joins(:model, :client, :location).where(["(crm_object_id regexp ? or serial_number regexp ? or models.nm regexp ? or clients.name regexp ? or locations.address1 regexp ?) and (primary_tech_id = ? or backup_tech_id = ?)", @search_str, @search_str, @search_str, @search_str, @search_str, current_technician.id, current_technician.id]).order(:crm_object_id).page(params[:page])
      end
      case @devices.length
      when 1
        @device = @devices.first
        redirect_to "/devices/#{@device.id}/#{session[:search_caller]}"
      when 0
        redirect_to devices_url, alert: "Nothing found."
      else
        render :index
      end
    else
      redirect_to back_or_go_here()
    end
  end
  
  def parts_for_multi_pm
    @tech = current_user
    
    # @dev_list controls which devs we generate parts list for. Must send back to form.
    @dev_list = params[:device] ? params[:device].each_key.map {|x| x} : params[:alldevs].each_key.map {|x| x}
    @devices = Device.find(@dev_list)
    # create @parts_hash = {dev1_id => [[code, choice, Part], [code, choice, Part], ...], ...}
    
    if params[:service]
      @msg_body = "Please create service orders for the following units:\n\n"
      @devices.each do |dev|
        @msg_body += "#{dev.crm_object_id} : #{dev.model.nm} s/n #{dev.serial_number} : #{dev.client.name}, #{dev.location.address1}, #{dev.location.city}\n"
      end
      render 'write_service_order'
    else
      @parts_hash = {}
      @all_parts = {}
      @choice = params[:choice] || Hash.new
      @devices.each do |dev|
        unless dev.nil?
          @parts_hash[dev] = []
          # See if any part has been checked to find alternate
          # params[:checked] = {'dev_N1' => {PmCode => choice, ...}, 'dev_N2' => {...}}, controls alternate parts
          choice_hash = {}
          @choice["dev_#{dev.id}"] = @choice["dev_#{dev.id}"].nil? ? {} : @choice["dev_#{dev.id}"]
          if params[:checked]
            checked = params[:checked]
            if checked["dev_#{dev.id}"]
              code_hash = checked["dev_#{dev.id}"]
              code_hash.each_key do |code|
                choice = @choice["dev_#{dev.id}"][code]
                num_choices = dev.model.model_group.parts_for_pms.joins(:pm_code).where("pm_codes.name = ?", code).order(:choice).group(:choice).map(&:choice).length
                @choice["dev_#{dev.id}"][code] = (choice.to_i + 1) % num_choices
              end  # code_hash.each
            end  # if checked[]
          end  # if params[:checked]
          dev.pm_parts(@choice["dev_#{dev.id}"]).each do |code, parts|
            parts.each do |p|
              @all_parts[p.part_id] = @all_parts[p.part_id].nil? ? p.quantity.to_f : (@all_parts[p.part_id] + p.quantity.to_f)
              if @choice["dev_#{dev.id}"][code].nil?
                @choice["dev_#{dev.id}"][code] = 0
              end
              @parts_hash[dev] << [code,@choice["dev_#{dev.id}"][code].to_i, p]
            end
          end  # dev.m_parts.each
        end
      end
    end
  end
  
  def write_parts_order
    @tech = current_user
    part_list = params[:part]
    @msg_body = @tech.preference.default_message + "\n\n"
    part_list.each do |id,qty|
      p = Part.find id
      @msg_body += "#{qty} X #{p.name} (#{p.description})\n"
    end
    @msg_body += "\n" + (@tech.preference.default_sig || '')
  end
  
  def handle_checked
    @tech = current_user
    @dev_list = params[:device] ? params[:device].each_key.map {|x| x} : params[:alldevs].each_key.map {|x| x}
    @devices = Device.find(@dev_list)
    if params[:service]
      @msg_body = "Please create service orders for the following units:\n\n"
      @devices.each do |dev|
        @msg_body += "#{dev.crm_object_id} : #{dev.model.nm} s/n #{dev.serial_number} : #{dev.client.name}, #{dev.location.address1}, #{dev.location.city}\n"
      end
      @msg_body += "\n" + (current_user.preference.default_sig || '')
      render 'write_service_order'
    elsif params[:parts]
      @parts_hash = {}
      @all_parts = {}
      @choice = params[:choice] || Hash.new
      @devices.each do |dev|
        @parts_hash[dev] = []
        # See if any part has been checked to find alternate
        # params[:checked] = {'dev_N1' => {PmCode => choice, ...}, 'dev_N2' => {...}}, controls alternate parts
        choice_hash = {}
        @choice["dev_#{dev.id}"] = @choice["dev_#{dev.id}"].nil? ? {} : @choice["dev_#{dev.id}"]
        if params[:checked]
          checked = params[:checked]
          if checked["dev_#{dev.id}"]
            code_hash = checked["dev_#{dev.id}"]
            code_hash.each_key do |code|
              choice = @choice["dev_#{dev.id}"][code]
              num_choices = dev.model.model_group.parts_for_pms.joins(:pm_code).where("pm_codes.name = ?", code).order(:choice).group(:choice).map(&:choice).length
              @choice["dev_#{dev.id}"][code] = (choice.to_i + 1) % num_choices
            end  # code_hash.each_key
          end  # if checked[]
        end  # if params[:checked]
        dev.pm_parts(@choice["dev_#{dev.id}"]).each do |code, parts|
          parts.each do |p|
            @all_parts[p.part_id] = @all_parts[p.part_id].nil? ? p.quantity.to_f : (@all_parts[p.part_id] + p.quantity.to_f)
            if @choice["dev_#{dev.id}"][code].nil?
              @choice["dev_#{dev.id}"][code] = 0
            end
            @parts_hash = {}
            @all_parts = {}
            @choice = params[:choice] || Hash.new
            @devices.each do |dev|
              @parts_hash[dev] = []
              # See if any part has been checked to find alternate
              # params[:checked] = {'dev_N1' => {PmCode => choice, ...}, 'dev_N2' => {...}}, controls alternate parts
              choice_hash = {}
              @choice["dev_#{dev.id}"] = @choice["dev_#{dev.id}"].nil? ? {} : @choice["dev_#{dev.id}"]
              if params[:checked]
                checked = params[:checked]
                if checked["dev_#{dev.id}"]
                  code_hash = checked["dev_#{dev.id}"]
                  code_hash.each_key do |c|
                    choice = @choice["dev_#{dev.id}"][c]
                    num_choices = dev.model.model_group.parts_for_pms.joins(:pm_code).where("pm_codes.name = ?", c).order(:choice).group(:choice).map(&:choice).length
                    @choice["dev_#{dev.id}"][c] = (choice.to_i + 1) % num_choices
                  end  # code_hash.each_key
                end  # if checked[]
              end  # if params[:checked]
              dev.pm_parts(@choice["dev_#{dev.id}"]).each do |c, parts|
                parts.each do |p|
                  @all_parts[p.part_id] = @all_parts[p.part_id].nil? ? p.quantity.to_f : (@all_parts[p.part_id] + p.quantity.to_f)
                  if @choice["dev_#{dev.id}"][c].nil?
                    @choice["dev_#{dev.id}"][c] = 0
                  end
                  @parts_hash[dev] << [c,@choice["dev_#{dev.id}"][c].to_i, p]
                end  # parts.each
              end  # dev.pm_parts(...).each
            end  # @devices.each
          end  # parts.each
        end  # dev.pm_parts.each
      end  # @devices.each
      render "parts_for_multi_pm"
    elsif params[:all_parts]
      @group = {}
      @devices.each do |dev|
        if @group[dev.model.model_group_id].nil?
          @group[dev.model.model_group_id] = PartsForPm.where(["model_group_id = ?", dev.model.model_group_id])
        end
      end
      render "all_parts"
    elsif params[:transfer]
      @title = "Start Device Transfer"
      @tech = current_user
      @dev_list = []
      @from_region = current_technician.team.name
      unless params[:to_team_id].blank? or Team.find(params[:to_team_id]).nil?
        to_team_id = params[:to_team_id]
        # TODO add each device to message body.
        @devices.each do |dev|
          if dev.transfer_to(params[:to_team_id])
            @dev_list << dev
          else
            current_user.logs.create(device_id: dev.id, message: "Could not initiate transfer for this device.")
          end
        end
        # find receiving manager
        @to_manager = Technician.where(["team_id = ? and manager = TRUE", to_team_id]).first
        if @to_manager.nil?
          flash[:error] = "Could not find a manager for the 'to' region"
          redirect_to back_or_go_here()
        elsif @dev_list.empty?
          flash[:error] = "No devices selected for transfer"
          redirect_to back_or_go_here()
        else
          render 'start_transfer'
        end
      else
        flash[:error] = 'Unknown "to region" for transfer.'
        redirect_to back_or_go_here()
      end
    elsif params[:showbackup] == 'true'
      redirect_to action: 'my_pm_list', showbackup: 'true'
    elsif params[:showbackup] == 'false'
      redirect_to action: 'my_pm_list', showbackup: 'false'
    else
      redirect_to back_or_go_here()
    end
  end

  def send_transfer
    unless params[:email].nil? or params[:device].nil?
      dev_id_list = params[:device] ? params[:device].each_key.map {|x| x} : params[:alldevs].each_key.map {|x| x}
      @dev_list = Device.find(dev_id_list)
      @from_region = current_technician.team.name
      email = params[:email]
      email_to = email[:to]
      email_from = email[:from]
      email_sub = email[:subject]
      email_cc = email[:cc]
      msg = email[:msg]
      DeviceMailer.send_transfer_request(email_to, email_cc, email_from, email_sub, msg, @from_region, @dev_list).deliver_now
      flash[:notice] = "Transfer request has been sent"
      redirect_to back_or_go_here
    else
      flash[:error] = 'Appropriate email parameters not found or no valid devices selected.'
      redirect_to back_or_go_here
    end
  end
  
# TODO Need to record the referer URI in log
  def send_order
    unless params[:email].nil?
      email = params[:email]
      email_to = email[:to]
      email_from = current_user.email
      email_sub = email[:subject]
      email_cc = email[:cc]
      msg_body = email[:msg]
      if email_to.nil? or email_to.empty?
        flash[:error] = "You must enter a valid 'To:' email address."
        render write_service_order
      else
        PartsMailer.send_order(email_to, email_cc, email_from, email_sub, msg_body).deliver_now
        flash[:notice] = "Message has been sent."
        if request.referer =~ /write_parts_order\Z/
          current_user.logs.create(message: "Parts order sent\n==============\n#{msg_body}")
        elsif request.referer =~ /write_service_order\Z/
          current_user.logs.create(message: "Service order sent\n==============\n#{msg_body}")
        else
          current_user.logs.create(message: "Message of unknown origin sent to:#{email_to} from:#{email_from} subject:#{email_sub}\n==============\n#{msg_body}")
        end
        redirect_to back_or_go_here
      end
    else
      flash[:error] = 'Appropriate email parameters not found.'
      redirect_to back_or_go_here
    end
  end
  
  def get_autocomplete_items(parameters)
    super(parameters).joins(:locations).where(["locations.team_id = ?", params[:team_id]]).group(:name)
  end
  
  def get_pm_codes_list
    d = Device.find(params[:id])
    respond_to do |format|
      format.html {}
      format.js {}
      format.json { render json: d.pm_codes }
    end
  end
  
  private
  def sort_column(c = '')
    params[:sort] || c
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
