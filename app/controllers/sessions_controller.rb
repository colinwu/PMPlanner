class SessionsController < ApplicationController
  def new
    @title = "PM Planner Login"
  end

  def create
    username = params[:username]
    tech = Technician.find_by_sharp_name(username)
    if tech
      ldap = Net::LDAP.new
      ldap.host = 'sec.sharpamericas.com'
      ldap.port = 389
      ldap.auth username, params[:password]
      params[:username] =~ /\\(.+)$/
      sAMAccountName = $1
      if ldap.bind
        session[:technician_id] = tech.id
        redirect_to root_path, notice: "Log in successful."
      else
        flash[:error] = "Suppied name and/or password incorrect."
        render :new
      end
    else
      flash[:notice] = "Sorry, you are not authorized to use this application."
      render :new
    end
    
  end

  def destroy
    session[:technician_id] = nil
    redirect_to root_url, notice: "Logged out."
  end
end
