class TechniciansController < ApplicationController
  before_action :authorize
  
  def index
    if current_technician.admin?
      @title = "Technicians"
      @technicians = Technician.all
    elsif current_technician.manager?
      @title = "My techs"
      @technicians = current_technician.my_techs
    end
  end

  def show
    @title = "Your Account Info"
    @technician = Technician.find(params[:id])
  end

  def new
    if current_technician.admin?
      @technician = Technician.new
    else
      flash[:notice] = "Sorry, only admins can add technicians."
      redirect_to root_url
    end
  end

  def create
    @technician = Technician.new(params[:technician])
    if @technician.save
      @technician.create_preference(
        limit_to_region: true,
        limit_to_territory: true,
        default_root_path: '/devices/my_pm_list',
        lines_per_page: 25,
        upcoming_interval: 2,
        default_to_email: 'sharpdirectparts@sharpsec.com',
        default_from_email: 'landriaultl@sharpsec.com'
        )
      current_technician.logs.create(message: "Successfully created technician #{@technician.id}")
      redirect_to @technician, :notice => "Successfully created technician."
    else
      render :action => 'new'
    end
  end

  def edit
    if current_technician.admin?
      @technician = Technician.find(params[:id])
      @title = "Edit Info for #{@technician.first_name} #{@technician.last_name}"
    else
      @title = "Change Your Password"
      @technician = current_technician
    end
  end

  def update
    if current_technician.admin?
      @technician = Technician.find(params[:id])
    else
      @technician = current_technician
      params[:technician][:id] = current_technician.id
    end
    if params[:technician][:password].blank? or params[:technician][:password].empty?
      params[:technician].delete('password')
      params[:technician].delete('password_confirmation')
    end
    if @technician.update_attributes(params[:technician])
      redirect_to technicians_url, :notice  => "Successfully updated technician."
    else
      render :action => 'edit'
    end
  end

  def destroy
    if current_technician.admin?
      if param[:id] == current_technician.id
        flash[:error] = "You can not delete yourself."
        redirect_to root_url
      else
        @technician = Technician.find(params[:id])
        @technician.destroy
        redirect_to technicians_url, :notice => "Successfully removed technician."
      end
    else
      flash[:notice] = "Only admins can delete technicians."
      redirect_to root_url
    end
  end
  
  def root_dispatch
    redirect_to current_technician.preference.default_root_path
  end
  
  def select_territory
    unless params[:tech_id].blank? or Technician.find(params[:tech_id]).nil?
      session[:tech_id] = params[:tech_id]
      flash[:notice] = "Territory selected"
      current_technician.logs.create(message: "Working with territory for technician #{params[:tech_id]}")
    else
      session[:tech_id] = nil
    end
    redirect_to devices_path
  end
end
