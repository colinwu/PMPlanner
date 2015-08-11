class ApplicationController < ActionController::Base
  protect_from_forgery
  before_action :configure_permitted_parameters, if: :devise_controller?
  
  def back_or_go_here(where = root_path)
    session[:uri].nil? ? where : session[:uri]
  end
  
  def you_are_here
    session[:uri] = request.env['REQUEST_URI']
  end

  
  protected
  
  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) {|u| u.permit(:first_name, :last_name, :email, :team_id, :friendly_name, :crm_id, :password, :password_confirmation)}
  end
end
