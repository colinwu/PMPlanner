class PmCodesController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news

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
    @pm_code = PmCode.new(pm_code_params)
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
      if @pm_code.update(pm_code_params)
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

  def pm_code_params
    params.require(:pm_code).permit( :name, :description, :colorclass )
  end
end
