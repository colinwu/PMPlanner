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
        session[:tech] = tech
        session[:user] = tech
        session[:active_at] = Time.now
        current_user.logs.create(message: "Logged in")
        current_user.update_attributes(current_sign_in_at: Time.now, current_sign_in_ip: request.env['REMOTE_ADDR'])
        redirect_to back_or_go_here(root_url), notice: "Log in successful."
      else
        flash[:error] = "Name and/or password incorrect."
        render :new
      end
    else
      flash[:notice] = "Sorry, you are not authorized to use this application."
      render :new
    end
    
  end

  def destroy
    current_user.logs.create(message: "Logged out")
    session[:tech] = nil
    session[:act_as] = nil
    session[:active_at] = nil
    redirect_to root_url, notice: "Logged out."
  end
end
