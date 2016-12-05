class ModelTargetsController < ApplicationController
  before_action :authorize
  def index
    respond_to do |format|
      format.html {@model_targets = ModelTarget.page(params[:page])}
      format.json {
        @model_targets = ModelTarget.all
        render json: @model_targets
      }
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
end
