class NewsController < ApplicationController
  before_action :set_news, only: [:show, :edit, :update, :destroy]
  before_action :authorize, :set_defaults, :fetch_news
  before_action :require_admin, except: [:index, :show]
  
  # GET /news
  # GET /news.json
  def index
    @news = News.all.order("activate desc").page(params[:page]).per_page(lpp)
    @page_title = "News"
  end

  # GET /news/1
  # GET /news/1.json
  def show
    @page_title = "News Item"
  end

  # GET /news/new
  def new
    @news = News.new(activate: Date.today)
  end

  # GET /news/1/edit
  def edit
  end

  # POST /news
  # POST /news.json
  def create
    @news = News.new(news_params)

    respond_to do |format|
      if @news.save
        Technician.find_each do |t|
          @news.unreads.create(technician_id: t.id)
        end
        
        format.html { redirect_to back_or_go_here(news_index_url), notice: 'News was successfully created.' }
        format.json { render :show, status: :created, location: @news }
      else
        format.html { render :new }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /news/1
  # PATCH/PUT /news/1.json
  def update
    respond_to do |format|
      if @news.update(news_params)
        Technician.find_each do |t|
          unless @news.show_flag && @news.unreads.exists?(technician_id: t.id)
            @news.unreads.create(technician_id: t.id)
          end
        end
        
        format.html { redirect_to back_or_go_here(news_index_url), notice: 'News was successfully updated.' }
        format.json { render :show, status: :ok, location: @news }
      else
        format.html { render :edit }
        format.json { render json: @news.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /news/1
  # DELETE /news/1.json
  def destroy
    @news.destroy
    respond_to do |format|
      format.html { back_or_go_here news_index_url, notice: 'News was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_news
      @news = News.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def news_params
      params.require(:news).permit(:note, :activate, :urgent, :show_flag)
    end
end
