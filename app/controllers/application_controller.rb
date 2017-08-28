class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def back_or_go_here(where = root_url)
    session[:uri].nil? ? where : session[:uri]
  end
  
  def you_are_here
    session[:uri] = request.env['REQUEST_URI']
  end
  
  def authorize
    if current_user.nil?
      redirect_to login_url
    elsif session[:active_at].nil? or ((Time.now - session[:active_at]) > 600)
      you_are_here
      current_user.logs.create(message: "Session timed out.")
#       session.destroy
      session[:tech] = nil
      session[:act_as] = nil
      session[:active_at] = nil
      session[:user] = nil
      session[:showbackup] = nil
      
      redirect_to login_url, alert: "Your session has timed out. Please log in again."
    else
      session[:active_at] = Time.now
    end
  end

  def require_admin
    unless current_user.admin?
      current_user.logs.create(message: "Admin privileges required to access #{request.env['REQUEST_URI']}")
      redirect_to current_user.preference.default_root_path, alert: "Access Denied."
    end
  end
  
  def require_manager
    unless current_user.manager? or current_user.admin?
      current_user.logs.create(message: "Manager privileges required to access #{request.env['REQUEST_URI']}")
      redirect_to current_user.preference.default_root_path, alert: "Access Denied."
    end
  end
  
  def set_defaults
    if session[:showbackup].nil?
      session[:showbackup] = current_user.preference.showbackup.to_s
    end
    WillPaginate.per_page = current_user.preference.lines_per_page
  end
  
  def lpp
    current_user.preference.lines_per_page
  end
  
  protected
  
  def current_technician
    unless session[:tech].nil?
      Technician.find session[:tech]
    else
      nil
    end
  end
    
  def current_user
    unless session[:user].nil?
      Technician.find session[:user]
    else
      nil
    end
  end
  
  helper_method :current_user
  helper_method :current_technician
end
