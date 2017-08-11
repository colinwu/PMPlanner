class TechniciansController < ApplicationController
  before_action :authorize
  helper_method :sort_column, :sort_direction
  
  def index
    if params[:sort].nil? or params[:sort].empty?
      @order = 'first_name'
    else
      @order = params[:sort]
    end
    if current_user.admin?
      @page_title = "Technicians"
      @technicians = Technician.all.joins(:team).order(@order)
    elsif current_user.manager?
      @page_title = "My Techs"
      @technicians = current_user.my_techs.joins(:team).order(@order)
    end
  end

  def show
    @title = "Your Account Info"
    @technician = Technician.find(params[:id])
  end

  def new
    if current_user.admin?
      @page_title = "Add Technician"
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
        default_root_path: '/devices/search',
        lines_per_page: 25,
        upcoming_interval: 2,
        default_to_email: 'sharpdirectparts@sharpsec.com'
      )
      current_user.logs.create(message: "Successfully created technician #{@technician.id}")
      redirect_to back_or_go_here, :notice => "Successfully created technician."
    else
      render :action => 'new'
    end
  end

  def edit
    if current_user.admin? or current_user.manager?
      @technician = Technician.find(params[:id])
      @page_title = "Edit Info for #{@technician.first_name} #{@technician.last_name}"
    else
      redirect_to back_or_go_here(current_user.preference.default_root_path), alert: "You are not permitted to edit technicians."
    end
  end

  def update
    if current_user.admin? or current_user.manager?
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
    if current_user.admin?
      if params[:id] == current_user.id
        flash[:error] = "You can not delete yourself."
        redirect_to root_url
      else
        @technician = Technician.find(params[:id])
        if @technician.primary_devices.empty? and @technician.backup_devices.empty?
          current_user.logs.create(message: "Technician #{@technician.full_name} deleted.")
          @technician.destroy
          flash[:notice] = "Successfully removed technician."
          redirect_to technicians_url
        else
          flash[:alert] = "#{@technician.full_name} still has devices assigned. Please reassign them first."
          redirect_to technicians_url
        end
      end
    else
      flash[:error] = "Only admins can delete technicians."
      redirect_to root_url
    end
  end
  
  def root_dispatch
    redirect_to current_user.preference.default_root_path
  end
  
  def select_territory
    unless params[:tech_id].blank?
      session[:tech] = params[:tech_id]
      flash[:notice] = "Territory selected"
      current_user.logs.create(message: "Working with territory for technician #{params[:tech_id]} (#{current_technician.full_name})")
    else
      session[:tech] = nil
    end
    redirect_to back_or_go_here(current_user.preference.default_root_path)
  end
  
  private
  
  def sort_column
    (Technician.column_names + ['teams.name']).include?(params[:sort]) ? params[:sort] : 'first_name'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
  
end
