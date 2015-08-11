class CounterDataController < ApplicationController
  def index
    @counter_data = CounterDatum.all
  end

  def show
    @counter_datum = CounterDatum.find(params[:id])
  end

  def new
    @counter_datum = CounterDatum.new
  end

  def create
    @counter_datum = CounterDatum.new(params[:counter_datum])
    if @counter_datum.save
      redirect_to @counter_datum, :notice => "Successfully created counter datum."
    else
      render :action => 'new'
    end
  end

  def edit
    @counter_datum = CounterDatum.find(params[:id])
  end

  def update
    @counter_datum = CounterDatum.find(params[:id])
    if @counter_datum.update_attributes(params[:counter_datum])
      redirect_to @counter_datum, :notice  => "Successfully updated counter datum."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @counter_datum = CounterDatum.find(params[:id])
    @counter_datum.destroy
    redirect_to counter_data_url, :notice => "Successfully destroyed counter datum."
  end
end
