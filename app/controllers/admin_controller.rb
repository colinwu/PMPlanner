class AdminController < ApplicationController
  before_action :authorize
  before_action :set_defaults
  
  def index
  end
end
