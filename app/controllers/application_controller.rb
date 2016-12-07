class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def back_or_go_here(where = root_path)
    session[:uri].nil? ? where : session[:uri]
  end
  
  def you_are_here
    session[:uri] = request.env['REQUEST_URI']
  end
  
  def authorize
    if current_technician.nil?
      redirect_to login_url, alert: "Please log in."
    elsif (Time.now - session[:active_at]) > 6000
      you_are_here
      current_technician.logs.create(message: "Session timed out.")
      redirect_to login_url, alert: "Your session has timed out. Please log in."
    else
      session[:active_at] = Time.now
    end
  end

  protected
  
  def current_technician
    session[:tech]
  end
  helper_method :current_technician
  
end
