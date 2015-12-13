class MovielistsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  before_action :set_movielist, only: [:show, :edit, :update, :destroy]

  # GET /movielists
  def index
    @movielists = Movielist.all
  end

  # GET /movielists/1
  def show
  end

  # GET /movielists/new
  def new
    @movielist = Movielist.new
  end

  # GET /movielists/1/edit
  def edit
  end

  # POST /movielists
  def create
    @movielist = Movielist.find_or_create_by(movielist_params2)

    respond_to do |format|
      if @movielist.save
        format.html { redirect_to movie_path(movielist_params2[:movie_id]), notice: 'Movie was successfully added to your list.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /movielists/1
  def update
    respond_to do |format|
      if @movielist.update(movielist_params)
        format.html { redirect_to @movielist, notice: 'MovieList was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /movielists/1
  def destroy
    list_id = @movielist.list_id
    @movielist.destroy
    respond_to do |format|
      format.html { redirect_to list_path(list_id), notice: 'Movie was successfully removed from your list.' }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movielist
      @movielist = Movielist.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movielist_params
      params.require(:movielist).permit(:movie_id, :list_id)
    end

    def movielist_params2
      params.permit(:movie_id, :list_id)
    end
end
