class ContactsController < ApplicationController
  before_action :authorize
  helper_method :sort_column, :sort_direction
  
  def index
    you_are_here
    @search_params = params[:search] || Hash.new
    if params[:search]
      search_ar = ['placeholder']
      where_ar = []
      unless @search_params[:name].nil? or @search_params[:name].blank?
        search_ar << @search_params[:name]
        where_ar << "name regexp ?"
      end
      
      search_ar[0] = where_ar.join(' and ')
    end
    unless params[:sort].nil?
      @order = sort_column + ' ' + sort_direction
    else
      @order = 'name'
    end
    @tech = current_technician.admin? ? Technician.find(params[:tech_id]) : current_technician
    if current_technician.admin?
      @title = "All contacts"
      
      @contacts = Contact.where(search_ar).order(@order).page(params[:page])
    else
      @title = "My Contacts"
      order = sort_column
      @contacts = current_technician.find_contacts(search_ar, sort_column.to_sym, sort_direction, current_technician.preference.limit_to_territory).paginate(:page => params[:page])
    end 
  end

  def show
    @contact = Contact.find(params[:id])
  end

  def new
    @title = "Add New Contact"
    @contact = Contact.new
    @clients = Client.all.order(:name)
  end

  def create
    @contact = Contact.new(params[:contact])
    if @contact.save
      redirect_to @contact, :notice => "Successfully created contact."
    else
      render :action => 'new'
    end
  end

  def edit
    @title = "Edit Contact"
    @contact = Contact.find(params[:id])
    @clients = Client.all.order(:name)
  end

  def update
    @contact = Contact.find(params[:id])
    if @contact.update_attributes(params[:contact])
      redirect_to contacts_url, :notice  => "Successfully updated contact."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    @contact.destroy
    redirect_to contacts_url, :notice => "Successfully destroyed contact."
  end
  
  private
  def sort_column
    params[:sort] || 'name'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
  
end
