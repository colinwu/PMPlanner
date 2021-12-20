class AdminController < ApplicationController
  before_action :authorize, :set_defaults, :fetch_news, :require_manager
  
  def index
    you_are_here
  end

  def new

  end
  
  def upload
    content = Array.new
    byebug
    uploaded_file = params[:megan]
    # There is a tempfile at uploaded_file.tempfile
    f = File.open(uploaded_file.tempfile)
    # do the Reading.process_ptn1 method here
    while (line = f.gets)
      content << line
      # do other cool stuff
    end
    f.close
  end
end
