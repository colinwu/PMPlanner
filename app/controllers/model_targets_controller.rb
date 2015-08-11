class ModelTargetsController < ApplicationController
  def index
    @model_targets = ModelTarget.all
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
      redirect_to @model_target, :notice => "Successfully created model target."
    else
      render :action => 'new'
    end
  end

  def edit
    @model_target = ModelTarget.find(params[:id])
  end

  def update
    @model_target = ModelTarget.find(params[:id])
    if @model_target.update_attributes(params[:model_target])
      redirect_to @model_target, :notice  => "Successfully updated model target."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @model_target = ModelTarget.find(params[:id])
    @model_target.destroy
    redirect_to model_targets_url, :notice => "Successfully destroyed model target."
  end
end
