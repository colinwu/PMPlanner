class TeamsController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news
  
  def index
    @page_title = "Teams"
    @teams = Team.all
  end

  def show
    @team = Team.find(params[:id])
    respond_to do |format|
      format.html {}
      format.json { render json: @team }
    end
  end

  def new
    @page_title = "Create Team"
    @team = Team.new
  end

  def create
    @team = Team.new(params[:team])
    if @team.save
      redirect_to teams_url, :notice => "Successfully created team."
    else
      render :action => 'new'
    end
  end

  def edit
    @page_title = "Edit Team Details"
    @team = Team.find(params[:id])
  end

  def update
    @team = Team.find(params[:id])
    if @team.update_attributes(params[:team])
      redirect_to teams_url, :notice  => "Successfully updated team."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @team = Team.find(params[:id])
    @team.destroy
    redirect_to teams_url, :notice => "Successfully deleted team."
  end
  
  # [NOTE] This assumes there's only one manager per region
  def manager
    @technician = Team.find(params[:id]).technicians.where("manager is true").first
    respond_to do |format|
      format.html { render html: "/technicians/#{@technician.id}" }
      format.json { render json: @technician }
    end
  end
  
  def techs
    @technicians = Team.find(params[:id]).technicians
    respond_to do |format|
      format.html { render html: "/technicians/index" }
      format.json { render json: @technicians }
    end
  end
end
