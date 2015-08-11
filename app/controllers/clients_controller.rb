class ClientsController < ApplicationController
  respond_to :json
  
  def index
    you_are_here
    @title = "Clients"
    @tech = current_technician.admin? ? Technician.find(params[:tech_id]) : current_technician
    @clients = Client.order(:name).page(params[:page])
  end

  def show
    @client = Client.find(params[:id])
  end

  def new
    @client = Client.new
  end

  def create
    @client = Client.new(params[:client])
    if @client.save
      redirect_to @client, :notice => "Successfully created client."
    else
      render :action => 'new'
    end
  end

  def edit
    you_are_here
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])
    if @client.update_attributes(params[:client])
      redirect_to @client, :notice  => "Successfully updated client."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    redirect_to clients_url, :notice => "Successfully destroyed client."
  end

  def get_info
    @client = Client.find(params[:id])
    @location = "#{@device.location.address1}\n#{@device.location.address2}\n#{@device.location.city}\n#{@device.location.province}\n#{@device.location.post_code}"
  end
  
  def get_locations
    selected_client = Client.find(params[:id])
    @locations = Array.new
#     Client.where(["name = ?", selected_client.name]).each do |c|
      @locations += selected_client.locations.where(["team_id = ?", current_technician.team_id])
#     end
    @locations.paginate(page: params[:page])
    render 'locations/index'
  end
  
end
