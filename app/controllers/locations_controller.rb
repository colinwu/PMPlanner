class LocationsController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news
  
  helper_method :sort_column, :sort_direction
  respond_to :json
  
  def index
    @page_title = "Locations"
    you_are_here
    search_ar = ['clients.name <> ""']
    where_ar = []
    @search_params = {}
    if params[:search]
      @search_params = params[:search].permit(:client_name, :address1, :address2, :city, :province, :post_code, :loc_notes)
      unless @search_params['client_name'].blank?
        search_ar <<  @search_params['client_name']
        where_ar << "clients.name regexp ?"
      end
      unless @search_params['address1'].blank?
        search_ar <<  @search_params['address1']
        where_ar << "address1 regexp ?"
      end
      unless @search_params['address2'].blank?
        search_ar <<  @search_params['address2']
        where_ar << "address2 regexp ?"
      end
      unless @search_params['city'].blank?
        search_ar <<  @search_params['city']
        where_ar << "city regexp ?"
      end
      unless @search_params['province'].blank?
        search_ar <<  @search_params['province']
        where_ar << "province regexp ?"
      end
      unless @search_params['post_code'].blank?
        search_ar <<  @search_params['post_code']
        where_ar << "post_code regexp ?"
      end
      unless @search_params['loc_notes'].blank?
        search_ar << @search_params['loc_notes']
        where_ar << "notes regexp ?"
      end
      
    end
    if params[:sort].nil? or params[:sort].empty?
      @order = 'clients.name'
    else
      @order = sort_column + ' ' + sort_direction
    end
    if current_technician.nil?
      if current_user.admin?
        search_ar[0] = ([search_ar[0]] + where_ar).join(' and ')
        @locations = Location.joins(:client).order(@order).where(search_ar).page(params[:page])
        @title = "All Locations"
      elsif current_user.manager?
        where_ar << "team_id = ?"
        search_ar << current_user.team_id
        search_ar[0] = where_ar.join(' and ')
        @title = "Locations in Region"
        @locations = Location.joins(:client).order(@order).where(search_ar).page(params[:page])
      end
    else
      where_ar << "devices.primary_tech_id = ?"
      search_ar << current_technician.id
      search_ar[0] = where_ar.join(' and ')
      @title = "Locations in my territory"
      @locations = Location.joins(:client,:devices).order(@order).where(search_ar).group('locations.id').page(params[:page])
    end
    respond_to do |format|
      format.json { render json: @locations }
      format.html
    end
  end

  def show
    @page_title = "Location Details"
    @location = Location.find(params[:id])
  end

  def new
    @page_title = "New Location"
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)
    if @location.save
      current_user.logs.create(message: "New location data: " + @location.inspect)
      flash[:notice] = "Successfully created location."
      redirect_to back_or_go_here(locations_url)
    else
      render :action => 'new'
    end
  end

  def edit
    @page_title = "Edit Location"
    @location = Location.find(params[:id])
    current_user.logs.create(message: "Editing location data: " + @location.inspect)
  end

  def update
    @location = Location.find(params[:id])
    if @location.update(location_params)
      current_user.logs.create(message: "Location updated: " + @location.inspect)
      flash[:notice]  = "Successfully updated location."
      redirect_to back_or_go_here(locations_url) 
    else
      render :action => 'edit'
    end
  end

  def destroy
    @location = Location.find(params[:id])
    if @location.devices.empty?
      current_user.logs.create(message: "Location deleted: " + @location.inspect)
      @location.destroy
      flash[:notice] = "Location data deleted."
    else
      flash[:error] = "This location has a device. Can not be deleted."
    end
    redirect_to back_or_go_here(locations_url)
  end
  
  def show_devices_at
    @search_params = params[:search] || Hash.new
    @location = Location.find(params[:id])
    @devices = @location.devices.paginate(:page => params[:page])
    @page_title = "Devices located at #{@location.address1}, #{@location.city}"
    render "/devices/index"
  end
  
  private
  def sort_column
    params[:sort] || 'clients.name'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
  
  def location_params
    params.require(:location).permit(:address1, :address2, :city, :province, :post_code, :notes, :client_id, :team_id)
  end
end
