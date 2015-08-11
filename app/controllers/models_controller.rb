class ModelsController < ApplicationController
  def index
    @models = Model.all
  end

  def show
    @model = Model.find(params[:id])
  end

  def new
    @model = Model.new
  end

  def create
    @model = Model.new(params[:model])
    if @model.save
      redirect_to @model, :notice => "Successfully created model."
    else
      render :action => 'new'
    end
  end

  def edit
    @model = Model.find(params[:id])
  end

  def update
    @model = Model.find(params[:id])
    if @model.update_attributes(params[:model])
      redirect_to @model, :notice  => "Successfully updated model."
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
