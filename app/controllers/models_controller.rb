class ModelsController < ApplicationController
  before_action :authorize
  def index
    @search_params = {}
    respond_to do |format|
      format.html {
        @models = Model.page(params[:page]).order(:nm)
        render erb: @models
      }
      format.json {
        @models = Model.all.order(:nm)
        render json: @models
      }
    end
  end

  def show
    @model = Model.find(params[:id])
  end

  def new
    if current_technician.admin? or current_technician.manager?
      @model = Model.new
      @pm_code = {}
      @section = {}
      @label = {}
    else
      redirect_to back_or_go_here(models_url), alert: "You are not permitted here."
    end
  end

  def create
    @model = Model.new(nm: params[:model][:nm])
    # Make sure model group exists and is properly associated with the model
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
    if @model.save
      redirect_to models_url, :notice => "Successfully created model."
    else
      render :action => 'new'
    end
  end

  def edit
    if current_technician.admin? or current_technician.manager?
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
    redirect_to models_url, :notice => "Successfully destroyed model."
  end
end
