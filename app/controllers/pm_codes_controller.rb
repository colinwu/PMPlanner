class PmCodesController < ApplicationController
  before_action :authorize
  before_action :set_defaults
  def index
    @pm_codes = PmCode.all
    respond_to do |format|
      format.html {}
      format.json { render json: @pm_codes }
    end
  end

  def show
    @pm_code = PmCode.find(params[:id])
  end

  def new
    @pm_code = PmCode.new
  end

  def create
    @pm_code = PmCode.new(params[:pm_code])
    if @pm_code.save
      redirect_to @pm_code, :notice => "Successfully created pm code."
    else
      render :action => 'new'
    end
  end

  def edit
    @pm_code = PmCode.find(params[:id])
  end

  def update
    @pm_code = PmCode.find(params[:id])
    respond_to do |format|
      if @pm_code.update_attributes(params[:pm_code])
        format.html {redirect_to @pm_code, :notice  => "Successfully updated pm code."}
        format.json {respond_with_bip(@pm_code)}
      else
        format.html {render :action => 'edit'}
        format.json {respond_with_bip(@pm_code)}
      end
    end
  end

  def destroy
    @pm_code = PmCode.find(params[:id])
    @pm_code.destroy
    redirect_to pm_codes_url, :notice => "Successfully destroyed pm code."
  end
end
