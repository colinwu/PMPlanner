class DevicesController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news
  before_action :require_manager, only: [:new, :create, :destroy, :send_transfer, :unassigned]
  helper_method :sort_column, :sort_direction
  # autocomplete :client, :name, full: true
  
  include ApplicationHelper
  
  def index
    you_are_here
    @page_title = replace_my + " Territory"
    if session[:showbackup].nil?
      session[:showbackup] = current_user.preference.showbackup.to_s
    end
    if params[:search].nil?
      @search_params = {}
    else
      @search_params = params[:search].permit(:crm,:model,:sn,:client_name,:addr1,:city).to_h
    end
    search_ar = ["active = true"]
    where_ar = []
    if @search_params
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
      search_ar[0] = ([search_ar[0]]+where_ar).join(' and ')
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
        @devices = Device.joins(:location, :client,:model).where(search_ar).order(@order).page(params[:page]).per_page(lpp)
      elsif current_user.manager?
        @title = "Devices in #{current_user.team.name}"
        @tech = current_user
        unless where_ar.empty?
          search_ar[0] = [search_ar[0], 'devices.team_id = ?'].join(' and ')
          search_ar << current_user.team_id
        else
          search_ar = ["devices.team_id = ?", current_user.team_id]
        end
        @devices = Device.joins(:location,:client,:model).where(search_ar).order(@order).page(params[:page]).per_page(lpp)
      else
        # should never reach this
        # @title = "My Territory"
        # @tech = current_user
      end
    else
      @title = "#{current_technician.friendly_name}'s Devices"
      @tech = current_technician
      unless where_ar.empty?
        if session[:showbackup] == 'true'
          search_ar[0] = [search_ar[0], '(primary_tech_id = ? or backup_tech_id = ?)'].join(' and ')
          search_ar << @tech.id
          search_ar << @tech.id
        else
          search_ar[0] = [search_ar[0], 'primary_tech_id = ?'].join(' and ')
          search_ar << @tech.id
        end
      else
        if session[:showbackup] == 'true'
          search_ar = ['primary_tech_id = ? or backup_tech_id = ?', @tech.id, @tech.id]
        else
          search_ar = ['primary_tech_id = ?', @tech.id]
        end
      end
      @devices = Device.joins(:location,:client,:model).where(search_ar).order(@order).page(params[:page]).per_page(lpp)
    end
    
    # if @devices.nil? or @devices.empty?
    #   @devices = @tech.primary_devices.joins(:location, :client, :model).where(search_ar).order(@order).page(params[:page]).per_page(lpp)
    # end
  end

  def show
    @device = Device.find(params[:id])
    @page_title = "Details for #{@device.serial_number}"
    if current_user.can_manage?(@device)
      you_are_here
      @manager = Technician.where(['team_id = ? and manager = TRUE', @device.team_id]).first
      @contacts = @device.location.contacts
    else
      flash[:alert] = 'You are not allowed to access that device.'
      redirect_to back_or_go_here
    end
  end

  def new
    @page_title = 'Add Device'
    you_are_here
    begin
      @device = Device.new(pm_counter_type: 'count', active: true, do_pm: true)
    rescue
      flash[:error] = "Could not create new device: #{@device.errors.message}"
      redirect_to back_or_go_here(root_url)
    end
    # only admin or manager can add devices
    if current_user.admin? or current_user.manager?
      @device.team_id = (current_technician.nil? or current_technician.team_id.nil?) ? Team.find_by(name: 'Admin').id : current_technician.team_id
      @readonly_flag = false
      @contacts = []
      @locations = []
    else
      redirect_to back_or_go_here, :alert => 'You are not allowed to add devices. Pease see your manager.'
    end
  end

  def create
    params[:device].delete(:model_nm)
    @device = Device.new(device_params)
    @readonly_flag = 'false'
    if params[:device][:model_id].empty?
      flash[:alert] = 'The model you specified is not known to PM Planner. Please make sure it is in the system before proceeding.'
      @locations = []
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
      
    if @device.save
      current_user.logs.create(device_id: @device.id, message: "Created device record with #{params[:device].inspect}")
      flash[:alert] = nil
      flash[:error] = nil
      flash[:notice] = "Successfully created device record."
      @device.create_neglected(next_visit: nil)
      @device.create_device_stat()
      @device.model.model_group.model_targets.where("maint_code <> 'AMV' and target > 0").each do |t|
        op = OutstandingPm.find_or_create_by(device_id: @device.id, code: t.maint_code)
        op.update_attributes(next_pm_date: params[:first_visit])
      end
      redirect_to back_or_go_here(edit_device_url(@device))
    else
      flash[:error] = "Please see error messages below."
      @locations = Location.where(["client_id = ? and team_id = ?", @device.client_id, @device.team_id])
      @contacts = @device.location.nil? ? [] : @device.location.contacts
      if current_user.can_manage?(@device)
        you_are_here
        @readonly_flag =  false
      else
        @readonly_flag =  true
        flash[:alert] = "You are only allowed to edit some settings."
      end
      render :action => 'new'
    end
  end

  def edit
    @page_title = "Edit device info"
    session[:caller] = request.path_parameters[:action]
    you_are_here
    @device = Device.find(params[:id])
    @locations = Location.where(["client_id = ?", @device.client_id])
    @location = Location.new
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
    params[:device].delete('model_nm')
    if @device.update_attributes(device_params)
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
      dev = @device.to_s
      if @device.destroy
        flash[:notice] = "Successfully removed device record."
        current_user.logs.create(message: "Deleted device #{dev}")
      else
        flash[:error] = "Could not delete device: #{@device.errors.messages}"
        current_user.logs.create(message: "Could not delete device: #{@device.errors.messages}")
      end
    else
      current_user.logs.create(device_id: @device.crm_object_id, message: "Not authorized to delete device")
      flash[:alert] = "Only admin or managers can delete devices."
    end
    redirect_to devices_url
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
  
  def analyze_data
    @page_title = "PM Status"
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
      else
        avg = @device.device_stat
      end
      @bw_monthly = avg[:bw_monthly]
      @c_monthly = avg[:c_monthly]
      dailyc = avg[:c_daily]
      dailybw = avg[:bw_daily]
      @vpy = avg[:vpy]
      
      @todays_reading = @device.readings.find_by_taken_at(@now)
      @prev_reading = @device.last_non_zero_reading_on_or_before(@now-1)
      
      unless @prev_reading.nil?
        last_now_interval = @now - @prev_reading.taken_at
        range = @tech.preference.upcoming_interval * 7
        if @device.model.model_group.color_flag
          last_c_val = @prev_reading.counter_for('ctotal').value
          c_estimate = @todays_reading.nil? ? (last_c_val + dailyc * last_now_interval) : @todays_reading.counter_for('ctotal').value
        end
      
        # Calculate BW stats
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
          bgclass = 'allgood'
        end
        
        # Record TotBW row
        @rows << [bgclass,
                'BWTOTAL',
                'Total Counter: BW',
                last_bw_val,
                bw_estimate.round,
                prog,
                next_pm_date.strftime("%b %-d, %Y")]
        
        if @device.model.model_group.color_flag
        # Record TotC row if there's any
          @rows << [bgclass,
                  'CTOTAL',
                  'Total Counter: Color',
                  last_c_val,
                  c_estimate.round,
                  prog,
                  next_pm_date.strftime("%b %-d, %Y")]
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
            estimate = @todays_reading.nil? ? (last_val + daily * last_now_interval) : @todays_reading.counter_for(c).try(:value)
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
              bgclass = 'allgood'
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
                      estimate.round, 
                      prog,
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
  
  # This action handles searching from the "Analysis", "Data Entry" and "History" screens.
  def do_search
    @search_params = {}
    if params[:commit] == 'Search' and not params[:search_str].blank?
      @search_str = params[:search_str]
      @target = params[:target]
      @title = "Search: #{@search_str}"
      if @target == 'All'
        @devices = Device.joins(:model, :client, :location, :primary_tech).where(["crm_object_id regexp ? or serial_number regexp ? or models.nm regexp ? or clients.name regexp ? or locations.address1 regexp ? or technicians.first_name regexp ? or technicians.last_name regexp ? or technicians.friendly_name regexp ?", @search_str, @search_str, @search_str, @search_str, @search_str, @search_str, @search_str, @search_str]).order(:crm_object_id).page(params[:page]).per_page(lpp)
      elsif @target == 'Region'
        @devices = Device.joins(:model, :client, :location, :primary_tech).where(["(crm_object_id regexp ? or serial_number regexp ? or models.nm regexp ? or clients.name regexp ? or locations.address1 regexp ? or technicians.first_name regexp ? or technicians.last_name regexp ? or technicians.friendly_name regexp ?) and devices.team_id = ?", @search_str, @search_str, @search_str, @search_str, @search_str, @search_str, @search_str, @search_str, current_technician.team_id]).order(:crm_object_id).page(params[:page]).per_page(lpp)
      else
        @devices = Device.joins(:model, :client, :location).where(["(crm_object_id regexp ? or serial_number regexp ? or models.nm regexp ? or clients.name regexp ? or locations.address1 regexp ?) and (primary_tech_id = ? or backup_tech_id = ?)", @search_str, @search_str, @search_str, @search_str, @search_str, current_technician.id, current_technician.id]).order(:crm_object_id).page(params[:page]).per_page(lpp)
      end
      case @devices.length
      when 1
        @device = @devices.first
        redirect_to "/devices/#{@device.id}/#{session[:search_caller]}"
      when 0
        flash[:error] = "Nothing found."
        redirect_to root_url
      else
        render :index
      end
    else
      redirect_to back_or_go_here()
    end
  end
  
  def enter_data
    @page_title = "Data Entry"
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
      @bw_monthly = stats[:bw_monthly]
      @c_monthly = stats[:c_monthly]
      @vpy = stats[:vpy]
      @last_reading = @device.last_non_zero_reading_on_or_before(@now)
    #         @last_reading = @device.readings.where("taken_at < '#{@now}'").order(:taken_at).last
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
  
  def handle_checked
    @tech = current_user
    @dev_list = params[:selected_devices] ? params[:selected_devices] : params[:alldevs]
    @devices = Device.find(@dev_list)
    if params[:service]
      @msg_body = "Please create PM order(s) for the following unit(s):\n\n"
      @devices.each do |dev|
        @msg_body += "#{dev.crm_object_id} : #{dev.model.nm} s/n #{dev.serial_number} : #{dev.client.name}, #{dev.location.address1}, #{dev.location.city}\n"
      end
      @msg_body += "\n" + (current_user.preference.default_sig || '')
      render 'write_service_order'
    elsif params[:parts]
      @parts_hash = {}
      @all_parts = {}
      @choice = params[:choice] || {}
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
      from_tech = current_technician
      to_tech_id = params[:to_tech_id]
      unless params[:to_tech_id].blank? and Technician.exists?(to_tech_id)
        @devices.each do |dev|
          if dev.primary_tech_id == from_tech.id
            dev.update_attributes(primary_tech_id: to_tech_id)
            current_user.logs.create(message: "Device s/n #{dev.serial_number} transfered to #{Technician.find(to_tech_id).friendly_name} as primary.")
          elsif dev.backup_tech_id = from_tech.id
            dev.update_attributes(backup_tech_id: to_tech_id)
            current_user.logs.create(message: "Device s/n #{dev.serial_number} transfered to #{Technician.find(to_tech_id).friendly_name} as backup.")
          else
            flash[:error] = "Device s/n #{dev.serial_number} was not assigned to #{from_tech} as either primary or backup."
          end
        end
      else
        flash[:error] = "No valid 'to' technician specified."
      end
      redirect_to back_or_go_here
    end
  end
  
  def show_or_hide_backup
    if params[:showbackup] == 'true'
      session[:showbackup] = "true"
      redirect_to request.env['HTTP_REFERER']
    elsif params[:showbackup] == 'false'
      session[:showbackup] = "false"
      redirect_to request.env['HTTP_REFERER']
    else
      redirect_to back_or_go_here()
    end
  end

  def my_pm_list
    # Shows list of devices whose next_pm_visit is either in the past or is within
    # range (as defined by the tech's preferences)
    you_are_here
    @page_title = replace_my + " PM List"
    @search_params = {}
    if params[:search]
      @search_params = params[:search].permit(:crm, :model, :sn, :client_name, :addr1, :city, :post_code)
    end
    if session[:showbackup].nil?
      session[:showbackup] = current_user.preference.showbackup.to_s
    end

    if current_technician.nil? # if I'm not working with any particular technician and...
      if (current_user.admin?) # ... I am an admin then I work with all techs' territories
        my_team = Technician.all.includes(:preference)
        @title = "PM List for all devices"
      elsif current_user.manager? # ... or if I'm a manager then I work with my region
        my_team = Technician.where(["team_id = ?",current_user.team_id]).includes(:preference)
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
      if session[:showbackup] == "true"
        where_ar = ["(devices.primary_tech_id = ? or devices.backup_tech_id = ?) and devices.active is true and devices.under_contract is true and devices.do_pm is true and (outstanding_pms.next_pm_date is not NULL and datediff(outstanding_pms.next_pm_date, curdate()) < #{range})"]
        search_ar = ["",tech.id, tech.id]
      else
        where_ar = ["primary_tech_id = ? and active is true and under_contract is true and do_pm is true and (outstanding_pms.next_pm_date is not NULL and datediff(outstanding_pms.next_pm_date, curdate()) < #{range})"]
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
        unless @search_params['post_code'].nil? or @search_params['post_code'].blank?
          search_ar << @search_params['post_code']
          where_ar << "locations.post_code regexp ?"
        end
      end
      search_ar[0] = where_ar.join(' and ')
      @code_count = {}
      @code_date = {}
      if (sort_column == 'outstanding_pms' or sort_column.empty?)
        # if sort_direction == 'desc'
        #   @order = 'desc'
        # else
        #   @order = 'asc'
        # end
        if params[:direction].nil?
          params[:direction] = 'asc'
          params[:sort] = 'outstanding_pms'
        end
        
        if (sort_direction == 'desc')
          @dev_list = Device.includes(:primary_tech, :outstanding_pms, :client, :model, :location).joins(:primary_tech, :outstanding_pms, :client, :model, :location).where(search_ar).group("devices.id").sort_by{|d| d.earliest_pm_date}.reverse.paginate(page: params[:page], per_page: lpp)
        else
          @dev_list = Device.includes(:primary_tech, :outstanding_pms, :client, :model, :location).joins(:primary_tech, :outstanding_pms, :client, :model, :location).where(search_ar).group("devices.id").sort_by{|d| d.earliest_pm_date}.paginate(page: params[:page], per_page: lpp)
        end
        @dev_list.each do |d|
          pm_list = d.outstanding_pms.where("next_pm_date is not NULL and datediff(next_pm_date, curdate()) < #{range}")
          @code_date[d.id] = pm_list.order("next_pm_date ASC").first.next_pm_date
          @code_count[d.id] = pm_list.length
        end
      else
        @dev_list = Device.includes(:primary_tech, :outstanding_pms, :client, :model, :location).joins(:primary_tech, :outstanding_pms, :client, :model, :location).where(search_ar).order(@order).references(:clients, :models, :locations).group(:id).page(params[:page]).per_page(lpp)
        @dev_list.each do |d|
          pm_list = d.outstanding_pms.where("next_pm_date is not NULL and datediff(next_pm_date, curdate()) < #{range}")
          @code_date[d.id] = pm_list.empty? ? d.neglected.next_visit : pm_list.order("next_pm_date ASC").first.next_pm_date
          @code_count[d.id] = pm_list.length
        end # Device.each
      end
    end
  end
  
  def parts_for_multi_pm
    @tech = current_user
    params.permit!
    # @dev_list controls which devs we generate parts list for. Must send back to form.
    @dev_list = params[:selected_devices] ? params[:selected_devices] : params[:alldevs]
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
      @choice = params[:choice].to_h || {}
      @devices.each do |dev|
        unless dev.nil?
          @parts_hash[dev] = []
          # See if any part has been checked to find alternate
          # params[:checked] = {'dev_N1' => {PmCode => choice, ...}, 'dev_N2' => {...}}, controls alternate parts
          choice_hash = {}
          @choice["dev_#{dev.id}"] = @choice["dev_#{dev.id}"].nil? ? {} : @choice["dev_#{dev.id}"]
          if params[:checked]
            checked = params[:checked].to_h
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
  
  def record_data
#     TODO: Should do some value sanity checking here
    @device = Device.find(params[:id])
    taken_at = Date.parse(params[:reading][:taken_at])
    @reading = @device.readings.find_or_create_by(taken_at: taken_at, technician_id: current_user.id)
    @reading.update_attributes(params.require(:reading).permit(:taken_at, :notes, :device_id, :technician_id, :ptn1))
    flash[:alert] = ''
    params[:counter].each do |code,value|
      p = PmCode.find_by_name(code)
      begin
        v = value.gsub(/[^0-9-]/,'')
        if v.empty?
          v = 0  # if value is empty make it zero
        end
        c = @reading.counters.find_or_create_by(pm_code_id: p.id)
        c.update_attributes!(value: v, unit: 'count')
      rescue
        flash[:alert] = "Error saving counter for #{p.name}. Value = #{v}"
        current_user.logs.create(device_id: @device.id, message: "Error saving counter for #{p.name}. Value = #{value}")
      end
    end
    current_user.logs.create(device_id: @device.id, message: "Counter data saved.")
    @device.update_pm_visit_tables
    # redirect_to analyze_data_device_url(@device)
    redirect_to current_user.preference.default_root_path
  end
  
  def rm_contact
    contact_id = params['contact']
    dev = Device.find(params['dev']) 
    dev.location.contacts.delete(contact_id)
    current_user.logs.create(device_id: dev.id, message: "contact #{contact_id} no longer associated with device")
    redirect_to back_or_go_here
  end
  
  def search
    session[:search_caller] = 'analyze_data'
    
  end
  
  def service_history
    @page_title = "PM History"
    session[:search_caller] = request.path_parameters[:action]
    you_are_here
    begin
      @device = Device.find(params[:id])
    rescue
      @device = nil
    end
    if @device.nil?
      flash[:alert] = "No valid device specified."
      render "service_history"
      return
    end
    
    if @device and current_user.can_manage?(@device)      
      @last_reading = @device.readings.order(:taken_at).last
      
      if @device.device_stat.nil?
        stats = @device.calculate_stats
      else
        stats = @device.device_stat
      end
        
      @bw_monthly = stats[:bw_monthly]
      @c_monthly = stats[:c_monthly]
      @vpy = stats[:vpy]
      
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
  
  def unassigned
    you_are_here
    @page_title = "Unassigned Devices"
    if session[:showbackup].nil?
      session[:showbackup] = current_user.preference.showbackup.to_s
    end
    @search_params = params[:search] || Hash.new
    search_ar = ["devices.team_id is NULL"]
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
      search_ar[0] = ([search_ar[0]]+where_ar).join(' and ')
    end
    if params[:sort].nil? or params[:sort].empty?
      @order = 'crm_object_id'
    else
      @order = sort_column + ' ' + sort_direction
    end
    
    @devices = Device.joins(:location, :client,:model).where(search_ar).order(@order).page(params[:page]).per_page(lpp)
    
    render :index
    
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
  
# TODO Need to record the referer URI in log
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

  def device_params
    params.require(:device).permit(:installed_base_id, :crm_object_id, :alternate_id, :model_id, :client_id, :serial_number, :location_id, :primary_tech_id, :backup_tech_id, :active, :under_contract, :do_pm, :pm_counter_type, :pm_visits_min, :notes, :team_id, :install_date)
  end
end
