class ModelGroupsController < ApplicationController
  before_action :authorize
  before_action :set_defaults
  before_action :require_admin, except: [:get_targets, :index, :show]
  def index
    @page_title = "Model Groups"
    respond_to do |format|
      format.html {
        you_are_here
        if params[:commit] == 'Search'
          search_ar = ['placeholder']
          where_ar = []
          unless params[:name].blank?
            search_ar << params[:name]
            where_ar << 'name regexp ?'
          end
          unless params[:desc].blank?
            search_ar << params[:desc]
            where_ar << 'description regexp ?'
          end
          unless params[:color].nil? or params[:color].blank?
            search_ar << params[:color]
            where_ar << 'color_flag = ?'
          end
          search_ar[0] = where_ar.join(' and ')
          @model_groups = ModelGroup.where(search_ar).order(:name).page(params[:page]).per_page(lpp)
        else
          @model_groups = ModelGroup.all.page(params[:page]).per_page(lpp)
        end 
      }
      format.json {
        @model_groups = ModelGroup.all
        render json: @model_groups
      }
    end
  end

  def show
    @page_title = "Model Group Details"
    you_are_here
    @model_group = ModelGroup.find(params[:id])
    @pm_code = {}
    @section = {}
    @label = {}
    @model_group.model_targets.each do |t|
      unless t.maint_code == 'AMV'
        c = t.maint_code
        @pm_code[c] = t.target
        @section[c] = t.section
        @label[c] = t.label
      end
    end
  end

  def new
    @page_title = "New Model Group"
    if current_user.admin? or current_user.manager?
      @model_group = ModelGroup.new(color_flag: true)
      @pm_code = {}
      @section = {}
      @label = {}
    else
      redirect_to back_or_go_here(model_groups_url), alert: "You are not permitted here."
    end
  end

  def create
    @model_group = ModelGroup.new(params[:model_group])
    @pm_code = params[:pm_code]
    @section = params[:section]
    @label = params[:label]
    if @model_group.color_flag
    end
    if @pm_code['TA'].empty?
      @pm_code['TA'] = @pm_code['DK'] || @pm_code['DRC']
    end
    
    if (@model_group.color_flag)
      if @pm_code['DC'].empty? or @pm_code['DM'].empty? or @pm_code['DY'].empty? or @pm_code['VC'].empty? or @pm_code['VM'].empty? or @pm_code['VY'].empty?
        render action: 'new', notice: "Some colour-dependent fields were left empty."
        return
      end
      if (@pm_code['CA'].empty?)
        @pm_code['CA'] = @pm_code['DC']
      end
    end
    @model_group.save
    # Update or create model targets
    @pm_code.keys.each do |c|
      unless @pm_code[c].empty? and @section[c].empty? and @label[c].empty?
        val = @pm_code[c].gsub(/[^0-9]/,'')
        mt = @model_group.model_targets.find_or_create_by(maint_code: c)
        mt.update_attributes(target: val, section: @section[c], label: @label[c], unit: 'count')
        mt.save
      end
    end
    
    if @model_group.save
      redirect_to model_groups_url, :notice => "Successfully created model group."
    else
      render :action => 'new'
    end
  end

  def edit
    @page_title = "Edit Model Group"
    @model_group = ModelGroup.find(params[:id])
    @pm_code = {}
    @section = {}
    @label = {}
    @model_group.model_targets.each do |t|
      unless t.maint_code == 'AMV'
        c = t.maint_code
        @pm_code[c] = t.target
        @section[c] = t.section
        @label[c] = t.label
      end
    end
  end

  def update
    @model_group = ModelGroup.find(params[:id])
    if @model_group.update_attributes(params[:model_group])
      @pm_code = params[:pm_code]
      @pm_code.each {|c,v| v.gsub!(/[^0-9-]/,'')}
      @section = params[:section]
      @label = params[:label]
      if @pm_code['TA'].empty?
        @pm_code['TA'] = @pm_code['DK'].empty? ? @pm_code['DRC'] : @pm_code['DK']
      end
      
      if (@model_group.color_flag)
        if @pm_code['DC'].empty? or @pm_code['DM'].empty? or @pm_code['DY'].empty? or @pm_code['VC'].empty? or @pm_code['VM'].empty? or @pm_code['VY'].empty?
          render action: 'edit', notice: "Some colour-dependent fields were left empty."
          return
        end
        if (@pm_code['CA'].empty?)
          @pm_code['CA'] = @pm_code['DC']
        end
      end
      @pm_code.keys.each do |c|
        unless @pm_code[c].empty? and @section[c].empty? and @label[c].empty?
          val = @pm_code[c].gsub(/[^0-9]/,'')
          mt = @model_group.model_targets.find_or_create_by(maint_code: c)
          mt.update_attributes(target: val, section: @section[c], label: @label[c], unit: 'count')
          mt.save
        end
        if @pm_code[c].empty?
          mt = @model_group.model_targets.find_by maint_code: c
          unless mt.nil?
            mt.destroy
          end
        end
      end
      redirect_to back_or_go_here(model_groups_path), :notice  => "Successfully updated model group."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @model_group = ModelGroup.find(params[:id])
    @model_group.destroy
    redirect_to model_groups_url, :notice => "Successfully deleted model group."
  end
  
  def get_targets
    @targets = ModelGroup.find(params[:id]).model_targets
    respond_to do |format|
      format.html {}
      format.json { render json: @targets }
    end
  end
end
