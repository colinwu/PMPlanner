class PartsController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news
  before_action :require_manager, only: [:new, :create, :destroy]

  def index
    @page_title = 'Parts List'
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
      @parts = Part.where(search_ar).page(params[:page]).per_page(lpp)
    else
      @parts = Part.page(params[:page]).per_page(lpp)
    end
    @model_str = Hash.new
    @parts.each do |part|
      model_list = []
      part.parts_for_pms.each do |pfp|
        pfp.model_group.models.each do |m|
          model_list << m.nm
        end
      end
      @model_str[part.name] = model_list.join(', ')
    end

    you_are_here
  end

  def show
    @page_title = 'Part Detail'
    @part = Part.find(params[:id])
  end

  def new
    @page_title = 'Add new part'
    @part = Part.new
  end

  def create
    @part = Part.new(part_params)
    if @part.save
      redirect_to @part, notice: 'Successfully created part.'
    else
      render :action => 'new'
    end
  end

  def edit
    @page_title = 'Edit Part'
    @part = Part.find(params[:id])
  end

  def update
    @part = Part.find(params[:id])
    if @part.update(part_params)
      redirect_to @part, notice: 'Successfully updated part.'
    else
      render :action => 'edit'
    end
  end

  def destroy
    @part = Part.find(params[:id])
    @part.destroy
    redirect_to parts_url, notice: 'Successfully deleted part.'
  end

  private

  def part_params
    params.require(:part).permit( :name, :description, :price, :new_name )
  end
end
