class MoviesController < ApplicationController
  respond_to :js, only: [:recommend, :bookmark, :hide]
  skip_before_action :authenticate_user!, only: [:index, :show, :poster_img]
  before_action :set_movie, only: [:show, :edit, :update, :destroy, :bookmark, :recommend, :hide]

  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.all.each(&:retrieve!)
    @movies = @movies - current_user.hiding if user_signed_in?
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



  def recommend
    @liked_state = nil
    if current_user.likes?(@movie) && params[:thumbs_up] == 'false' ||
        !current_user.dislikes?(@movie) && !current_user.likes?(@movie) && params[:thumbs_up] == 'false'
      current_user.dislike(@movie)
      @liked_state = :disliked
    elsif current_user.likes?(@movie) && params[:thumbs_up] == 'true'
      current_user.unlike(@movie)
    elsif current_user.dislikes?(@movie) && params[:thumbs_up] == 'true' ||
        !current_user.dislikes?(@movie) && !current_user.likes?(@movie) && params[:thumbs_up] == 'true'
      current_user.like(@movie)
      @liked_state = :liked
    elsif current_user.dislikes?(@movie) && params[:thumbs_up] == 'false'
      current_user.undislike(@movie)
    end
  end

  def bookmark
    if current_user.bookmarks?(@movie)
      current_user.unbookmark(@movie)
    else
      current_user.bookmark(@movie)
    end
  end

  def hide
    current_user.hide(@movie)
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
