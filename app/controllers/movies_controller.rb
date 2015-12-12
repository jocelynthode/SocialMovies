class MoviesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show, :poster_img]
  before_action :set_movie, only: [:show, :edit, :update, :destroy, :poster_img]

  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.all
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
    ok, data = RemoteData.omdb_query(@movie.imdb)
    if ok
      @plot = data[:Plot]
      @poster_url = data[:Poster]
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
    @movie = Movie.find_or_create_by(:mid => movie_params_mid[:mid])

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Redirect to actual imdb URL
  def poster_img
    ok, data = RemoteData.omdb_query(@movie.imdb)
    if ok
      redirect_to data[:Poster], status: :moved_permanently
    else
      render nothing: true, status: :not_found
    end
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
