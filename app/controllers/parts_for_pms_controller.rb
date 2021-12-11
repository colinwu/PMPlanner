class PartsForPmsController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news
  before_action :require_admin, only: [:new, :create, :edit, :update, :destroy]
  helper_method :sort_column, :sort_direction
  
  # autocomplete :part, :name, full: true
  
  def index
    you_are_here
    @search_params = {}
    if params[:search]
      @search_params = params[:search].permit(:model_group, :pmcode, :choice, :pn, :desc).to_h
    end
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
      @order = 'model_groups.name,pm_codes.name'
    else
      @order = sort_column + ' ' + sort_direction
    end
    @parts_for_pms = PartsForPm.joins(:model_group,:part, :pm_code).where(search_ar).order(@order).page(params[:page]).per_page(lpp)
    if @parts_for_pms.group(:model_group_id).length == 1
      @new_pfp = PartsForPm.new(model_group_id: @parts_for_pms[0].model_group_id)
    else
      @new_pfp = PartsForPm.new()
    end
    respond_to do |format|
      format.html {}
      format.json { render json: @parts_for_pms }
    end
  end

  def show
    @parts_for_pm = PartsForPm.find(params[:id])
  end

  def new
    redirect_to parts_for_pms_url, notice: "Add new parts link at the bottom."
  end
  
  def create
    mg = ModelGroup.find_by params[:model_group]
    code = PmCode.find_or_create_by params[:pm_code]
    part = Part.find_or_create_by params[:part]
    if mg.nil?
      redirect_to new_model_group_url, :alert => "Specified Model Group (#{params[:model_group][:name]}) does not exist. Either create it first or correct your entry."
    else
      @parts_for_pm = PartsForPm.new(model_group_id: mg.id, pm_code_id: code.id, part_id: part.id, choice: params[:parts_for_pm][:choice], quantity: params[:parts_for_pm][:quantity])
      if @parts_for_pm.save
        redirect_to back_or_go_here, :notice => "Successfully created parts for pm."
      else
        redirect_to back_or_go_here, :alert => "Failed to create Part Link."
      end
    end
  end

  def edit
    @parts_for_pm = PartsForPm.find(params[:id])
  end

  def update
    @parts_for_pm = PartsForPm.find(params[:id])
    if @parts_for_pm.update(parts_for_pm_params)
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

  def parts_for_pm_params
    params.require(:parts_for_pm).permit( :model_group_id, :pm_code_id, :choice, :part_id, :quantity )
  end
  
end
