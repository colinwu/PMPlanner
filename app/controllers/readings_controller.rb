class ReadingsController < ApplicationController
  before_action :authenticate_technician!, :except => [:sign_in]

  def index
    @readings = Reading.order(:taken_at).page(params[:page])
  end

  def show
    @reading = Reading.find(params[:id])
  end

  def new
    @reading = Reading.new
  end

  def create
    @reading = Reading.new(params[:reading])
    if @reading.save
      redirect_to @reading, :notice => "Successfully created reading."
    else
      render :action => 'new'
    end
  end

  def edit
    @reading = Reading.find(params[:id])
  end

  def update
    @reading = Reading.find(params[:id])
    if @reading.update_attributes(params[:reading])
      redirect_to @reading, :notice  => "Successfully updated reading."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @reading = Reading.find(params[:id])
    @reading.destroy
    redirect_to readings_url, :notice => "Successfully destroyed reading."
  end
end
