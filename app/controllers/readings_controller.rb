class ReadingsController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news
  
  def index
    @readings = Reading.order(:taken_at).page(params[:page]).per_page(lpp)
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
        current_user.logs.create(device_id: @reading.device.crm_object_id, message: "Processing PTN1 fie #{@reading.ptn1_file_name}")
        msg = @reading.process_ptn1
        if msg == "22-6 file processed."
          current_user.logs.create(device_id: @reading.device.crm_object_id, message: "Counters saved from #{@reading.ptn1_file_name}.")
	  @reading.device.update_pm_visit_table
          redirect_to back_or_go_here(@reading), :notice => "Reading successfully saved."
        else
          current_user.logs.create(device_id: @reading.device.crm_object_id, message: "Encountered an error processing #{@reading.ptn1_file_name}: #{msg}.")
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
