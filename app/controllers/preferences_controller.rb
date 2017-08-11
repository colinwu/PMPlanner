class PreferencesController < ApplicationController
  before_action :authorize
  
  def index
    @page_title = "Profiles"
    unless current_user.admin?
      redirect_to edit_preferences_path(current_technician)
    else
      @preferences = Preference.all
    end
  end

  def show
    @technician_id = params[:id]
    @preference = Preference.find_by_technician_id(@technician_id)
  end

  def new
    unless current_user.admin?
      redirect_to edit_preferences_path(current_technician), :alert => "Only admin can create new technician profile."
    else
      @preference = Preference.new(
        limit_to_region: true,
        limit_to_territory: true,
        default_root_path: '/devices/search',
        lines_per_page: 25,
        upcoming_interval: 2,
        default_to_email: 'sharpdirectparts@sharpsec.com',
        default_from_email: ''
      )
    end
  end

  def create
    @preference = Preference.new(params[:preference])
    if @preference.save
      redirect_to @preference, :notice => "Successfully created preference."
    else
      render :action => 'new'
    end
  end

  def edit
    @page_title = "Edit Preferences"
    if current_user.admin?
      @technician = Technician.find params[:id]
    else
      if params[:id].to_i != current_user.id
        flash[:notice] = "You can only edit your own profile."
      end
      @technician = current_user
    end
    @preference = @technician.preference
  end

  def update
    @preference = Preference.find(params[:id])
    if @preference.update_attributes(params[:preference])
      current_user.logs.create(message: "Preference data updated: #{params[:preference].inspect}")
      redirect_to @preference.default_root_path
      current_user.preference(true)
    else
      render :action => 'edit'
    end
  end

  def destroy
    unless current_user.admin?
      redirect_to back_or_go_here, :alert => "You are not permitted to delete technician profiles."
    else
      @preference = Preference.find(params[:id])
      @preference.destroy
      current_user.logs.create(message: "Preference for technician #{params[:id]} deleted.")
      redirect_to preferences_url, :notice => "Successfully destroyed preference."
    end
  end
end
