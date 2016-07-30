class CountersController < ApplicationController
  def index
    @counters = Counter.all
  end

  def show
    @counter = Counter.find(params[:id])
  end

  def new
    @counter = Counter.new
  end

  def create
    @counter = Counter.new(params[:counter])
    if @counter.save
      redirect_to @counter, :notice => "Successfully created counter."
    else
      render :action => 'new'
    end
  end

  def edit
    @counter = Counter.find(params[:id])
  end

  def update
    byebug
    @counter = Counter.find(params[:id])
    respond_to do |format|
      if @counter.update_attributes(params[:counter])
        format.html {redirect_to((back_or_go_here(root_path)), :notice => "Update successful") }
        format.json {respond_with_bip(@counter)}
      else
        format.html {render :action => 'edit'}
        format.json {respond_with_bip(@counter)}
      end
    end
  end

  def destroy
    @counter = Counter.find(params[:id])
    @counter.destroy
    redirect_to counters_url, :notice => "Successfully destroyed counter."
  end
end
