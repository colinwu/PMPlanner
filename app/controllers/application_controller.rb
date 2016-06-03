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
    end
  end

  protected
  
  def current_technician
    Technician.where(id: session[:tech_id]).first
  end
  helper_method :current_technician
  
end
