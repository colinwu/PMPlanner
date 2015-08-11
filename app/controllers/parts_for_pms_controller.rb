class PartsForPmsController < ApplicationController
  before_action :authenticate_technician!, :except => [:sign_in]
  helper_method :sort_column, :sort_direction
  
  def index
    you_are_here
    @search_params = params[:search] || Hash.new
    if params[:search]
      search_ar = ['placeholder']
      where_ar = []
      unless @search_params['model_group'].blank?
        where_ar << 'model_groups.name regexp ?'
        search_ar << @search_params['model_group']
      end
      unless @search_params['pmcode'].blank?
        where_ar << 'pm_codes.name regexp ?'
        search_ar << @search_params['pmcode']
      end
      unless @search_params['choice'].blank?
        where_ar << 'choice = ?'
        search_ar << @search_params['choice']
      end
      unless @search_params['pn'].blank?
        where_ar << 'parts.name regexp ?'
        search_ar << @search_params['pn']
      end
      unless @search_params['desc'].blank?
        where_ar << 'parts.description regexp ?'
        search_ar << @search_params['desc']
      end
      search_ar[0] = where_ar.join(' and ')
    end
    if params[:sort].nil? or params[:sort].empty?
      @order = 'model_groups.name'
    else
      @order = sort_column + ' ' + sort_direction
    end
    @parts_for_pms = PartsForPm.joins(:model_group,:part, :pm_code).where(search_ar).order(@order).page(params[:page])
  end

  def show
    @parts_for_pm = PartsForPm.find(params[:id])
  end

  def new
    @parts_for_pm = PartsForPm.new
  end

  def create
    @parts_for_pm = PartsForPm.new(params[:parts_for_pm])
    if @parts_for_pm.save
      redirect_to @parts_for_pm, :notice => "Successfully created parts for pm."
    else
      render :action => 'new'
    end
  end

  def edit
    @parts_for_pm = PartsForPm.find(params[:id])
  end

  def update
    @parts_for_pm = PartsForPm.find(params[:id])
    if @parts_for_pm.update_attributes(params[:parts_for_pm])
      redirect_to @parts_for_pm, :notice  => "Successfully updated parts for pm."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @parts_for_pm = PartsForPm.find(params[:id])
    @parts_for_pm.destroy
    redirect_to parts_for_pms_url, :notice => "Successfully destroyed parts for pm."
  end
  
  private
  def sort_column(c = '')
    params[:sort] || c
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
  
end
