class MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :poster_img]
  before_action :set_movie, only: [:show, :edit, :update, :destroy, :toggle_bookmark, :toggle_recommendation, :hide]

  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.all.each(&:retrieve!)
    @lists = List.order("name ASC").where("user_id = ?", current_user.id)
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
    ok, data = RemoteData.omdb_query(@movie.imdb)
    if ok
      @plot = data[:Plot]
      @poster_url = data[:Poster] unless data[:Poster] == 'N/A'
    else
      flash[:warning] = 'Cannot retrieve details from IMDB'
    end

    @lists = List.order("name ASC").where("user_id = ?", current_user.id)
    # @movielists = Movielist.where("movie_id = ?", params[:id])
    # puts @lists
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies
  # POST /movies.json
  def create
    # @movie = Movie.new(movie_params)
    @movie = Movie.find_or_create_by(:id => movie_params_mid[:mid])

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
      else
        format.html { render :new }
      end
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
      else
        format.html { render :edit }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
    end
  end

  # Redirect to actual imdb URL
  def poster_img
    ok, data = RemoteData.omdb_query(params[:imdb_id])
    if ok
      redirect_to data[:Poster], status: :moved_permanently
    else
      head :not_found
    end
  end

  def toggle_recommendation
    if current_user.likes?(@movie)
      current_user.dislike(@movie)
    else
      current_user.like(@movie)
    end
    redirect_to :back
  end

  def toggle_bookmark
    if current_user.bookmarks?(@movie)
      current_user.unbookmark(@movie)
    else
      current_user.bookmark(@movie)
    end
    redirect_to :back
  end

  def hide
    current_user.hide(@movie)
    redirect_to :back
  end

  private
    # Use callbacks to share common setup or constraints between actions.

    def set_movie
      @movie = Movie.retrieve params[:id]
      if not @movie
        flash[:alert] = "Movie not found"
        index and render 'index', status: 404
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params_mid
      params.permit(:mid)
    end

    def movie_params
      params.require(:movie).permit(:mid)
    end
end
