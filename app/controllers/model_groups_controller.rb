class ModelGroupsController < ApplicationController
  before_action :authorize
  def index
    respond_to do |format|
      format.html {
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
          @model_groups = ModelGroup.where(search_ar).order(:name).page(params[:page])
        else
          @model_groups = ModelGroup.all.page(params[:page])
        end 
      }
      format.json {
        @model_groups = ModelGroup.all
        render json: @model_groups
      }
    end
  end

  def show
    @model_group = ModelGroup.find(params[:id])
  end

  def new
    @model_group = ModelGroup.new
  end

  def create
    @model_group = ModelGroup.new(params[:model_group])
    if @model_group.save
      redirect_to model_groups_url, :notice => "Successfully created model group."
    else
      render :action => 'new'
    end
  end

  def edit
    @model_group = ModelGroup.find(params[:id])
  end

  def update
    @model_group = ModelGroup.find(params[:id])
    if @model_group.update_attributes(params[:model_group])
      redirect_to @model_group, :notice  => "Successfully updated model group."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @model_group = ModelGroup.find(params[:id])
    @model_group.destroy
    redirect_to model_groups_url, :notice => "Successfully destroyed model group."
  end
  
  def get_targets
    @targets = ModelGroup.find(params[:id]).model_targets
    respond_to do |format|
      format.html {}
      format.json { render json: @targets }
    end
  end
end
