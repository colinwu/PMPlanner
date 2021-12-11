class ClientsController < ApplicationController
  respond_to :json
  before_action :authorize, :set_defaults, :fetch_news
  before_action :require_admin
  
  def index
    you_are_here
    @page_title = "Clients"
#     @tech = current_user.admin? ? Technician.find(params[:tech_id]) : current_user
    @clients = Client.order(:name).page(params[:page]).per_page(lpp)
    respond_to do |format|
      format.html {
        @clients = Client.order(:name, :soldtoid).page(params[:page]).per_page(lpp)
        render erb: @clients
      }
      format.json {
        @clients = Client.order(:name).select(:id, :name)
        render json: @clients
      }
    end

  end

  def show
    @client = Client.find(params[:id])
    @page_title = "Details for #{@client.name}"
  end

  def new
    @page_title = 'Create New Client'
    @client = Client.new
  end

  def create
    @client = Client.new(client_params)
    if @client.save
      redirect_to clients_path, notice: 'Successfully created client.'
    else
      render action: 'new'
    end
  end

  def edit
    @page_title = 'Edit Client'
    you_are_here
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])
    if @client.update(client_params)
      redirect_to clients_path, notice: 'Successfully updated client.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    redirect_to clients_url, notice: 'Successfully deleted client.'
  end

  def get_info
    @client = Client.find(params[:id])
    @location = "#{@device.location.address1}\n#{@device.location.address2}\n#{@device.location.city}\n#{@device.location.province}\n#{@device.location.post_code}"
  end
  
  def get_locations
    selected_client = Client.find(params[:id])
    @locations = []
    @locations += selected_client.locations
    render 'locations/index'
  end
  
  private

  def set_client
    @client = Client.find(params[:id])
  end
  
  def client_params
    params.require(:client).permit(:name, :address, :address2, :city, :province, :postal_code, :notes, :soldtoid)
  end
end
