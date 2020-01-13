class TechniciansController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news
  helper_method :sort_column, :sort_direction
  
  def index
    you_are_here
    if params[:sort].nil? or params[:sort].empty?
      @order = 'first_name'
    else
      @order = params[:sort]
    end
    # if current_user.admin?
    #   @page_title = "Technicians"
    #   @technicians = Technician.all.joins(:team).order(@order)
    # elsif current_user.manager?
    if current_user.manager? or current_user.admin?
      @page_title = "My Techs"
      @technicians = current_user.my_techs.joins(:team).order(@order)
    end
  end

  def show
    @title = "Your Account Info"
    @technician = Technician.find(params[:id])
  end

  def new
    if current_user.manager? || current_user.admin?
      @page_title = "Add Technician"
      @technician = Technician.new
    else
      flash[:notice] = "Sorry, only admins and managers can add technicians."
      redirect_to root_url
    end
  end

  def create
    @technician = Technician.new(tech_params)
    @technician.email =~ /([^@]+)@/
    @technician.sharp_name = "sec\\#{$1}"
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
      redirect_to back_or_go_here(current_user.preference.default_root_path), alert: 'You are not permitted to edit technicians.'
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
    # If the current technician is the manager 
    if @technician.update_attributes(tech_params)
      if current_user.admin? and @technician.manager?
        team = @technician.team
        unless team.manager.nil? or team.manager == @technician
          current_user.logs.create(message: "#{team.manager.full_name} is no longer manager for #{team.name}")
          team.manager.update_attributes manager: false
        end
        team.update_attributes manager: @technician
        current_user.logs.create(message: "#{@technician.full_name} is the new manager for #{team.name}")
      end
      redirect_to technicians_url, :notice  => 'Successfully updated technician.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    session[:op] = "DELETE"
    if current_user.admin? or current_user.manager?
      if params[:id] == current_user.id
        flash[:error] = 'You can not delete yourself.'
        redirect_to root_url
      else
        @technician = Technician.find(params[:id])
        if @technician.primary_devices.empty? and @technician.backup_devices.empty?
          current_user.logs.create(message: "Technician #{@technician.full_name} deleted.")
          @technician.destroy
          flash[:notice] = 'Successfully removed technician.'
          redirect_to technicians_url
        else
          flash[:alert] = "#{@technician.full_name} still has devices assigned. Please reassign them first."
          session[:from_tech_id] = @technician.id
          redirect_to select_to_technicians_url
        end
      end
    else
      flash[:error] = 'Only admins can delete technicians.'
      redirect_to root_url
    end
  end
  
  def select_to
    @from_tech = Technician.find session[:from_tech_id]
  end

  def act_as
    unless params[:tech_id].blank?
      t = Technician.find(params[:tech_id])
      current_user.logs.create(message: "Pretending to be #{t.friendly_name}")
      session[:user] = t.id
      session[:tech] = t.id
      session[:mobile] = current_user.preference.mobile ? 'hidden-xs' : ''
      session[:showbackup] = current_user.preference.showbackup.to_s
    end
    redirect_to current_user.preference.default_root_path
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
  
  def transfer_territory
    unless params[:from_tech_id].blank? or params[:to_tech_id].blank?
      from_tech = Technician.find(params[:from_tech_id])
      to_tech = Technician.find(params[:to_tech_id])
      from_tech.primary_devices.each do |d1|
        d1.update_attributes primary_tech_id: to_tech.id
      end
      from_tech.backup_devices.each do |d1|
        d1.update_attributes backup_tech_id: to_tech.id
      end
      current_user.logs.create(message: "Devices serviced by #{from_tech.full_name} reassigned to #{to_tech.full_name}")
    end
    if session[:op] == 'DELETE'
      fn = from_tech.full_name
      from_tech.destroy
      flash[:notice] = "Technician #{fn} successfully deleted."
      current_user.logs.create(message: "Technician #{fn} successfully deleted.")
      session[:op] = nil
    end
    redirect_to back_or_go_here(admin_path)
  end

  def mark_news_read
    current_user.news.where("activate <= curdate()").each do |n|
      current_user.unreads.where(news_id: n.id).first.destroy
    end
    respond_to do |format|
      format.html {redirect_to back_or_go_here(root_url)}
      format.json {head :no_content}
    end
  end
  
  private
  
  def set_technician
    @technician = Technician.find(params[:id])
  end
  
  def sort_column
    (Technician.column_names + ['teams.name']).include?(params[:sort]) ? params[:sort] : 'first_name'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end

  def tech_params
    params.require(:technician).permit( :team_id, :first_name, :last_name, :friendly_name, :sharp_name, :car_stock_number, :email, :crm_id, :remember_me, :admin, :manager, :current_sign_in_at, :current_sign_in_ip, :sent_date )
  end

end
