class AdminController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news, :require_admin
  
  def index
    you_are_here
  end
end
