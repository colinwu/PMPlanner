class AdminController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news, :require_manager
  
  def index
    @transfer = Transfer.new
    you_are_here
  end
end
