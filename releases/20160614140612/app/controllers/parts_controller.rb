class PartsController < ApplicationController
  def index
    if params[:commit] == 'Search'
      search_ar = ['placeholder']
      where_ar = []
      unless params[:pn].blank?
        search_ar << params[:pn]
        where_ar << 'name regexp ?'
      end
      unless params[:desc].blank?
        search_ar << params[:desc]
        where_ar << 'description regexp ?'
      end
      search_ar[0] = where_ar.join(' and ')
      @parts = Part.where(search_ar).page(params[:page])
    else
      @parts = Part.page(params[:page])
    end
    you_are_here
  end

  def show
    @part = Part.find(params[:id])
  end

  def new
    @title = "Add new part"
    if current_technician.admin?
      @part = Part.new
    else
      @uri = back_or_default()
      redirect_to @uri, :notice => "Sorry, you are not allowed to add new parts."
    end
  end

  def create
    @part = Part.new(params[:part])
    if @part.save
      redirect_to @part, :notice => "Successfully created part."
    else
      render :action => 'new'
    end
  end

  def edit
    @part = Part.find(params[:id])
  end

  def update
    @part = Part.find(params[:id])
    if @part.update_attributes(params[:part])
      redirect_to @part, :notice  => "Successfully updated part."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @part = Part.find(params[:id])
    @part.destroy
    redirect_to parts_url, :notice => "Successfully destroyed part."
  end
end
