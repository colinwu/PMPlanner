class SessionsController < ApplicationController
  before_action :fetch_news
  
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
      begin
        if ldap.bind
          session[:user] = tech.id
          session[:active_at] = Time.now
          current_user.update_attributes(current_sign_in_at: Time.now, current_sign_in_ip: request.env['REMOTE_ADDR'])
          current_user.logs.create(message: "Logged in from #{request.env['REMOTE_ADDR']}")
          unless current_user.admin? or current_user.manager?
            session[:tech] = tech.id
          end
          redirect_to back_or_go_here(current_user.my_home), notice: "Log in successful."
        else
          Log.create(message: "Failed authentication: user = #{username}")
          flash[:error] = "Name and/or password incorrect."
          render :new
        end
      rescue
        flash[:error] = 'Could not establish connection to authentication server.'
        Log.create(message: "Could not establish connection to #{ldap.host}")
        redirect_to login_path
      end
    else
      Log.create(message: "Unknown tech: #{username }")
      flash[:notice] = "Sorry, you are not authorized to use this application. Please contact your manager."
      render :new
    end
    
  end

  def destroy
    current_user.logs.create(message: "Logged out")
    current_user.update_attributes(last_sign_in_at: current_user.current_sign_in_at)
#     session[:tech] = nil
#     session[:act_as] = nil
#     session[:active_at] = nil
#     session[:user] = nil
#     session[:uri] = nil
#     session[:showbackup] = nil
    session.destroy
    redirect_to root_url, notice: "Logged out."
  end
end
