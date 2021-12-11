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
    
    if @reading.ptn1_file_name
      if @reading.ptn1_file_name =~ /_(\d+)_PTN/
        fdate = Date.parse($1.slice(0,8))
        r = Reading.where(["taken_at = ? and device_id = ?", fdate, @reading.device_id]).first
        # if a reading for the same date already exists, take its identity (id) then delete it
        unless r.nil?
          @reading.id = r.id
          r.destroy
        end

        # have to save the instance before we can process the attached file
        if @reading.save
          if @reading.ptn1_file_name
            current_user.logs.create(device_id: @reading.device.crm_object_id, message: "Processing PTN1 file #{@reading.ptn1_file_name}")
            msg = @reading.process_ptn1
            if msg == "PTN1 file processed."
              current_user.logs.create(device_id: @reading.device.crm_object_id, message: "Counters saved from #{@reading.ptn1_file_name}.")
              @reading.device.update_pm_visit_tables 
              # PTN1 file successfully processed - now can delete it
              @reading.ptn1 = nil
              @reading.save
              redirect_to back_or_go_here(@reading), notice: 'Reading successfully saved.'
            else
              current_user.logs.create(device_id: @reading.device.crm_object_id, message: "Encountered an error processing #{@reading.ptn1_file_name}: #{msg}.")
              @reading.destroy
              redirect_to back_or_go_here(root_url), :alert => msg
            end
          end
        else
          render :action => 'new'
        end
      else
        redirect_to back_or_go_here(root_url), :alert => "Supplied file is not a PTN1 file."
      end
    end
  end

  def edit
    @reading = Reading.find(params[:id])
  end

  def new_upload
    # This is where techs can upload PTN1 files without having to select a device first.
    you_are_here
    @reading = Reading.new(device_id: 1, technician_id: current_user.id)
  end

  def update
    @reading = Reading.find(params[:id])
    respond_to do |format|
      if @reading.update(reading_params)
        format.html {redirect_to @reading, notice: 'Successfully updated reading.'}
        format.json {respond_with_bip(@reading)}
      else
        format.html {render :action => 'edit', notice: 'Problem with data.'}
        format.json {respond_with_bip(@reading)}
      end
    end
  end

  def destroy
    @reading = Reading.find(params[:id])
    @reading.device.logs.create(technician_id: current_user.id, message: "Deleted counter data from #{@reading.taken_at}")
    @reading.destroy
    redirect_to back_or_go_here(readings_url)
  end
  private

  def reading_params
    params.require(:reading).permit(:taken_at, :notes, :device_id, :technician_id, :ptn1, :unit)
  end

end

