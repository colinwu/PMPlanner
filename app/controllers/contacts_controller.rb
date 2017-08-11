class ContactsController < ApplicationController
  before_action :authorize
  helper_method :sort_column, :sort_direction
  
  def index
    you_are_here
    @page_title = "Contacts"
    @search_params = params[:search] || Hash.new
    search_ar = []
    if params[:search]
      search_ar = ['placeholder']
      where_ar = []
      unless @search_params[:name].blank?
        search_ar << @search_params[:name]
        where_ar << "name regexp ?"
      end
      unless @search_params[:phone1].blank?
        search_ar << @search_params[:phone1]
        where_ar << "phone1 regexp ?"
      end
      unless @search_params[:phone2].blank?
        search_ar << @search_params[:phone2]
        where_ar << "phone2 regexp ?"
      end
      unless @search_params[:email].blank?
        search_ar << @search_params[:email]
        where_ar << "email regexp ?"
      end
      unless @search_params[:location].blank?
        search_ar << @search_params[:location]
        search_ar << @search_params[:location]
        search_ar << @search_params[:location]
        search_ar << @search_params[:location]
        search_ar << @search_params[:location]
        where_ar << "(locations.address1 regexp ? or locations.address2 regexp ? or locations.city regexp ? or locations.province regexp ? or locations.post_code regexp ?)"
      end
      search_ar[0] = where_ar.join(' and ')
    end
    unless params[:sort].nil?
      @order = sort_column + ' ' + sort_direction
    else
      @order = 'name'
    end
    @tech = current_technician
    if current_user.admin?
      @title = "All contacts"
      @contacts = Contact.joins(:location).where(search_ar).order(@order).page(params[:page])
    else
      @title = "My Contacts"
      @contacts = current_technician.find_contacts(search_ar, sort_column, sort_direction, current_technician.preference.limit_to_territory,params[:page])
    end 
    
  end

  def show
    @page_title = "Contact Details"
    @contact = Contact.find(params[:id])
  end

  def new
    @page_title = "Add New Contact"
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
    @page_title = "Edit Contact"
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
    redirect_to contacts_url, :notice => "Successfully deleted contact."
  end
  
  private
  
  def sort_column
    (Contact.column_names + ['locations.address1']).include?(params[:sort]) ? params[:sort] : 'name'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
  
end
