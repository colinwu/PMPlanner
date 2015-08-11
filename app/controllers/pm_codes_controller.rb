class PmCodesController < ApplicationController
  def index
    @pm_codes = PmCode.all
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
    if @pm_code.update_attributes(params[:pm_code])
      redirect_to @pm_code, :notice  => "Successfully updated pm code."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @pm_code = PmCode.find(params[:id])
    @pm_code.destroy
    redirect_to pm_codes_url, :notice => "Successfully destroyed pm code."
  end
end
