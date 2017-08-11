class PartsController < ApplicationController
  before_action :authorize
  before_action :require_manager, only: [:new, :create, :destroy]
  
  def index
    @page_title = "Parts List"
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
    @page_title = "Part Detail"
    @part = Part.find(params[:id])
  end

  def new
    @page_title = "Add new part"
    @part = Part.new
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
    @page_title = "Edit Part"
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
    redirect_to parts_url, :notice => "Successfully deleted part."
  end
end
