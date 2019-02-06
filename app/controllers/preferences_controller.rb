class PreferencesController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news
  
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
      redirect_to edit_preferences_path(current_technician), :alert => 'Only admin can create new technician profile.'
    else
      @preference = Preference.new(
        default_root_path: '/devices/search',
        lines_per_page: 25,
        upcoming_interval: 2,
        default_to_email: 'sharpdirectparts@sharpsec.com',
        default_from_email: ''
      )
    end
  end

  def create
    @preference = Preference.new(preference_params)
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
    if @preference.update_attributes(preference_params)
      current_user.logs.create(message: "Preference data updated: #{params[:preference].inspect}")
      session[:mobile] = @preference.mobile ? 'hidden-xs' : ''
      redirect_to @preference.default_root_path
      current_user.preference
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

  def preference_params
    params.require(:preference).permit( :default_notes, :default_units_to_show, :upcoming_interval, :default_to_email, :default_subject, :default_from_email, :default_message, :default_sig, :max_lines, :technician_id, :lines_per_page, :default_root_path, :showbackup, :pm_list_freq, :pm_list_freq_unit, :mobile )
  end
end
