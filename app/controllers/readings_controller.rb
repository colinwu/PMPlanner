class ReadingsController < ApplicationController
  before_action :authorize
  
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
    @reading = Reading.new(reading_params)
    # have to save the instance before we can process the attached file
    if @reading.save
      if @reading.ptn1_file_name
        msg = @reading.process_ptn1
        if msg =~ /processed/
          redirect_to back_or_go_here(@reading), :notice => "Reading successfully saved."
        else
          @reading.destroy
          redirect_to back_or_go_here(root_url), :alert => msg
        end
      end
    else
      render :action => 'new'
    end
  end

  def edit
    @reading = Reading.find(params[:id])
  end

  def update
    byebug
    @reading = Reading.find(params[:id])
    respond_to do |format|
      if @reading.update_attributes(reading_params)
        format.html {redirect_to @reading, :notice  => "Successfully updated reading."}
        format.json {respond_with_bip(@reading)}
      else
        format.html {render :action => 'edit', :notice => "Problem with data."}
        format.json {respond_with_bip(@reading)}
      end
    end
  end

  def destroy
    @reading = Reading.find(params[:id])
    @reading.destroy
    redirect_to back_or_go_here(readings_url)
  end
end

private

def reading_params
  params.require(:reading).permit(:taken_at, :notes, :device_id, :technician_id, :ptn1)
end
