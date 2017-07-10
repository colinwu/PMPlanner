class ModelTargetsController < ApplicationController
  before_action :authorize
  before_action :set_defaults
  
  def index
    @search_params = params[:search] || Hash.new
    if params[:search]
      search_ar = ['placeholder']
      where_ar = []
      unless @search_params['model_group'].blank?
        where_ar << 'model_groups.name regexp ?'
        search_ar << @search_params['model_group']
      end
      unless @search_params['pmcode'].blank?
        where_ar << 'maint_code regexp ?'
        search_ar << @search_params['pmcode']
      end
      search_ar[0] = where_ar.join(' and ')
    end
    if params[:sort].nil? or params[:sort].empty?
      @order = 'model_groups.name'
    else
      @order = sort_column + ' ' + sort_direction
    end
    @model_targets = ModelTarget.joins(:model_group).where(search_ar).order(@order).page(params[:page])
    respond_to do |format|
      format.html {}
      format.json { render json: @model_targets }
    end
  end

  def show
    @model_target = ModelTarget.find(params[:id])
  end

  def new
    @model_target = ModelTarget.new
  end

  def create
    @model_target = ModelTarget.new(params[:model_target])
    if @model_target.save
      redirect_to model_targets_url, :notice => "Successfully created model target."
    else
      render :action => 'new'
    end
  end

  def edit
    @model_target = ModelTarget.find(params[:id])
  end

  def update
    @model_target = ModelTarget.find(params[:id])
    respond_to do |format|
      if @model_target.update_attributes(params[:model_target])
        format.html {redirect_to model_target_url, :notice  => "Successfully updated model target."}
        format.json {respond_with_bip(@model_target)}
      else
        format.html {render :action => 'edit'}
        format.json {respond_with_bip(@model_target)}
      end
    end
  end

  def destroy
    @model_target = ModelTarget.find(params[:id])
    @model_target.destroy
    redirect_to model_targets_url, :notice => "Successfully destroyed model target."
  end
  
  private
  def sort_column(c = '')
    params[:sort] || c
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
