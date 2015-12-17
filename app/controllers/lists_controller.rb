class ListsController < ApplicationController
  skip_before_action :authenticate_user!, only: []
  before_action :set_list, only: [:show, :edit, :update, :destroy]

  # GET /lists
  def index
    if user_signed_in?
      @lists = current_user.lists.order("name ASC")
      @friends_lists = current_user.following_by_type('List')
    else
      @lists = ''
      @friends_lists = ''
    end
  end

  # GET /lists/1
  def show
  end

  # GET /lists/new
  def new
    @list = List.new
  end

  # GET /lists/1/edit
  def edit
  end

  # POST /lists
  def create
    @list = List.new(list_params)
    @list.user_id = current_user.id

    respond_to do |format|
      if @list.save
        format.html { redirect_to @list, notice: 'List was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /lists/1
  def update
    respond_to do |format|
      if @list.update(list_params)
        format.html { redirect_to @list, notice: 'List was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /lists/1
  def destroy
    @list.destroy
    respond_to do |format|
      format.html { redirect_to lists_url, notice: 'List was successfully destroyed.' }
    end
  end


  private

  def get_bookmarks
    list = List.find_by_name('Bookmarks')
    list.movies = current_user.bookmarked_movies
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_list
    @list = List.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def list_params
    params.require(:list).permit(:name, :user_id)
  end
end
