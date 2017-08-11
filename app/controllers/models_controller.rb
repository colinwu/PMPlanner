class ModelsController < ApplicationController
  before_action :authorize
  before_action :require_admin, only: [:destroy, :new, :create]
  
  def index
    @page_title = "Models"
    @search_params = params[:search] || {}
    search_ar = ["place holder"]
    where_ar = []
    unless (@search_params[:nm].nil? or @search_params[:nm].empty?)
      search_ar << @search_params[:nm]
      where_ar << "models.nm regexp ?"
    end
    unless (@search_params[:mg].nil? or @search_params[:mg].empty?)
      search_ar << @search_params[:mg]
      where_ar << "model_groups.name regexp ?"
    end
    unless (@search_params[:desc].nil? or @search_params[:desc].empty?)
      search_ar << @search_params[:desc]
      where_ar << "model_groups.description regexp ?"
    end
    if where_ar.length > 0
      search_ar[0] = where_ar.join(" and ")
    else
      search_ar = []
    end
    respond_to do |format|
      format.html {
        @models = Model.joins(:model_group).where(search_ar).page(params[:page]).order(:nm)
        render erb: @models
      }
      format.json {
        @models = Model.where(search_ar).order(:nm)
        render json: @models
      }
    end
  end

  def show
    @model = Model.find(params[:id])
    @page_title = "Details for #{@model.nm}"
  end

  def new
    @page_title = "New Model"
    if current_user.admin? or current_user.manager?
      @model = Model.new
      @pm_code = {}
      @section = {}
      @label = {}
    else
      redirect_to back_or_go_here(models_url), alert: "You are not permitted here."
    end
  end

  def create
    name = params[:model][:nm].gsub(/\W/,'')
    @model = Model.new(nm: name)
    # Make sure model group exists and is properly associated with the model
    mg_name = params[:model][:model_group_id].empty? ? name : ModelGroup.find(params[:model][:model_group_id]).name
    @model_group = ModelGroup.find_or_create_by(name: mg_name)
    @model.model_group_id = @model_group.id
    counters = params[:pm_code]
    sections = params[:section]
    labels = params[:label]
    if counters['TA'].empty?
      counters['TA'] = counters['DK'] || counters['DRC']
    end
    
    if (counters['DC'].empty?)
      @model_group.color_flag = false
    else
      if (counters['CA'].empty?)
        counters['CA'] = counters['DC']
      end
      @model_group.color_flag = true
    end
    @model_group.save
    # Update or create model targets
    counters.keys.each do |c|
      unless counters[c].empty? and sections[c].empty? and labels[c].empty?
        val = counters[c].gsub(/[^0-9]/,'')
        mt = @model_group.model_targets.find_or_create_by(maint_code: c)
        mt.update_attributes(target: val, section: sections[c], label: labels[c], unit: 'count')
        mt.save
      end
    end
    if @model.save
      redirect_to models_url, :notice => "Successfully created model."
    else
      @pm_code = {}
      @section = {}
      @label = {}
      
      render :action => 'new'
    end
  end

  def edit
    @page_title = "Edit Model Details"
    if current_user.admin? or current_user.manager?
      @model = Model.find(params[:id])
      @pm_code = {}
      @section = {}
      @label = {}
      @model.model_group.model_targets.each do |t|
        @pm_code[t.maint_code] = t.target
        @section[t.maint_code] = t.section
        @label[t.maint_code] = t.label
      end
    else
      redirect_to back_or_go_here(models_url), :warning => "You are not permitted here."
    end
  end

  def update
    @model = Model.find(params[:id])
    mg_name = params[:model_group].empty? ? params[:model][:nm] : params[:model_group]
    @model_group = ModelGroup.find_or_create_by(name: mg_name)
    @model.model_group_id = @model_group.id
    counters = params[:pm_code]
    sections = params[:section]
    labels = params[:label]
    if counters['TA'].empty?
      counters['TA'] = counters['DK'] || counters['DRC']
    end
    
#     if @model_group.color_flag.nil?
      if (counters['DC'].empty?)
        @model_group.color_flag = false
      else
        if (counters['CA'].empty?)
          counters['CA'] = counters['DC']
        end
        @model_group.color_flag = true
      end
      @model_group.save
#     end
    # Update or create model targets
    counters.keys.each do |c|
      unless counters[c].empty? and sections[c].empty? and labels[c].empty?
        val = counters[c].gsub(/[^0-9]/,'')
        mt = @model_group.model_targets.find_or_create_by(maint_code: c)
        mt.update_attributes(target: val, section: sections[c], label: labels[c], unit: 'count')
        mt.save
      end
    end
    if @model.update_attributes(params[:model])
      redirect_to models_url, :notice  => "Successfully updated model."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @model = Model.find(params[:id])
    @model.destroy
    redirect_to models_url, :notice => "Successfully deleted model."
  end
end
