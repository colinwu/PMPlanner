class TechniciansController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news
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
    if @technician.update_attributes(tech_params)
      redirect_to technicians_url, :notice  => 'Successfully updated technician.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    if current_user.admin?
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
          redirect_to technicians_url
        end
      end
    else
      flash[:error] = 'Only admins can delete technicians.'
      redirect_to root_url
    end
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
