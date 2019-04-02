class LogsController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news
  before_action :set_log, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    if params[:search].nil?
      @search_params = {}
    else
      @search_params = params[:search].permit(:tech, :device, :message).to_h
    end
    search_ar = ['place_holder']
    join_tech = false;
    join_dev = false;
    where_ar = []
    if @search_params
      unless @search_params['tech'].nil? or @search_params['tech'].blank?
        search_ar <<  @search_params[:tech]
        search_ar <<  @search_params[:tech]
        where_ar << "(technicians.first_name regexp ? or technicians.last_name regexp ?)"
        join_tech = true;
      end
      unless  @search_params['device'].nil? or  @search_params['device'].blank?
        search_ar <<  @search_params[:device]
        where_ar << "devices.crm_object_id regexp ?"
        join_dev = true;
      end
      unless  @search_params['message'].nil? or  @search_params['message'].blank?
        search_ar <<  @search_params[:message]
        where_ar << "message regexp ?"
      end
      search_ar[0] = (where_ar).join(' and ')
    end
    if search_ar[0] == ''
      @logs = Log.order("created_at desc").page(params[:page])
    else
      if (join_tech and join_dev)
        @logs = Log.joins(:technician, :device).where(search_ar).order("created_at desc").page(params[:page])
      elsif (join_tech and not join_dev)
        @logs = Log.joins(:technician).where(search_ar).order("created_at desc").page(params[:page])
      elsif (not join_tech and join_dev)
        @logs = Log.joins(:device).where(search_ar).order("created_at desc").page(params[:page])
      else
        @logs = Log.where(search_ar).order("created_at desc").page(params[:page])
      end
    end
    respond_with(@logs)
  end

  def show
    respond_with(@log)
  end

  def new
    @log = Log.new
    respond_with(@log)
  end

  def edit
  end

  def create
    @log = Log.new(log_params)
    if params[:log][:technician_id].nil? or params[:log][:technician_id].empty?
      @log.technician_id = current_user.id
    end
    @log.save
    respond_with(@log)
  end

  def update
    @log.update(log_params)
    respond_with(@log)
  end

  def destroy
    @log.destroy
    respond_with(@log)
  end

  private
    def set_log
      @log = Log.find(params[:id])
    end

    def log_params
      params.require(:log).permit(:technician_id, :device_id, :message)
    end
end
