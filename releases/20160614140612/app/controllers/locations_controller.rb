class LocationsController < ApplicationController
  helper_method :sort_column, :sort_direction
  respond_to :json
  
  def index
    you_are_here
    search_ar = ['placeholder']
    where_ar = []
    @search_params = params[:search] || Hash.new
    if params[:search]
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
    if current_technician.admin?
      search_ar[0] = where_ar.join(' and ')
      @locations = Location.joins(:client).order(@order).where(search_ar).page(params[:page])
      @title = "All Locations"
    elsif current_technician.manager?
      where_ar << "team_id = ?"
      search_ar << current_technician.team_id
      search_ar[0] = where_ar.join(' and ')
      @title = "Locations in Region"
      @locations = Location.joins(:client).order(@order).where(search_ar).page(params[:page])
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
    @location = Location.find(params[:id])
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(params[:location])
    if @location.save
      flash[:notice] = "Successfully created location."
      redirect_to back_or_go_here(locations_url)
    else
      render :action => 'new'
    end
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    @location = Location.find(params[:id])
    if @location.update_attributes(params[:location])
      flash[:notice]  = "Successfully updated location."
      redirect_to back_or_go_here(locations_url) 
    else
      render :action => 'edit'
    end
  end

  def destroy
    @location = Location.find(params[:id])
    @location.destroy
    flash[:notice] = "Successfully destroyed location."
    redirect_to back_or_go_here(locations_url)
  end
  
  def show_devices_at
    @search_params = params[:search] || Hash.new
    @location = Location.find(params[:id])
    @devices = @location.devices.paginate(:page => params[:page])
    @title = "Devices located at #{@location.address1}, #{@location.city}"
    render "/devices/index"
  end
  
  private
  def sort_column
    params[:sort] || 'clients.name'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
  
end
