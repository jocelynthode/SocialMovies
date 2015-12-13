class SearchController < ApplicationController
  skip_before_action :authenticate_user!

  def index
  end


  # Search by actor name
  # return list of movies (title + id) based on actor
  def actor
    #actor_name = 'Jack Nicholson'
    # @actor_name = params[:actor_name] # in order to be available in the view
    q = %Q(
      SELECT ?id ?title ?actorName ?releaseDate
      WHERE {
        ?a rdf:type movie:actor .
        ?a movie:actor_name ?actorName .
        FILTER regex(?actorName, '^.*#{search_query(true)}', 'i')
        ?movies rdf:type movie:film .
        ?movies rdfs:label ?title .
        ?movies movie:actor ?a .
        ?movies movie:filmid ?id .
        ?movies movie:initial_release_date ?releaseDate .
      }
      ORDER BY ?title
    )
    res = RemoteData.linkedmdb_query(q)
    @movies = res[:results][:bindings].each do |movie|
      movie[:matching_value] = movie[:actorName][:value]
    end
    render 'results', locals: {title: "Movies with one of the actor name containing '#{search_query}"}
  end

  # Search by movie name
  # return list of movies (title + id) based on movie name
  def movie
    #movie_name = 'Batman'
    # @movie_name = params[:movie_name] # in order to be available in the view
    q = %Q(
      SELECT ?id ?title ?releaseDate
      WHERE {
        ?movies rdf:type movie:film .
        ?movies rdfs:label ?title .
        FILTER regex(?title, '^.*#{search_query(true)}', 'i')
        ?movies movie:filmid ?id .
        ?movies movie:initial_release_date ?releaseDate .
      }
      ORDER BY ?title
    )
    res = RemoteData.linkedmdb_query(q)
    @movies = res[:results][:bindings]
    render 'results', locals: {title: "Movies with title containing '#{search_query}'"}
  end

  # Search by year
  # return list of movies (title + id) based on year
  def year
    #movie_year = '2014'
    # @movie_year = params[:movie_year] # in order to be available in the view
    q = %Q(
      SELECT ?id ?title ?releaseDate
      WHERE {
        ?movies rdf:type movie:film .
        ?movies rdfs:label ?title .
        ?movies movie:initial_release_date ?releaseDate .
        FILTER regex(?releaseDate, '^#{search_query(true)}')
        ?movies movie:filmid ?id .
      }
      ORDER BY ?title
    )
    res = RemoteData.linkedmdb_query(q)
    @movies = res[:results][:bindings]
    render 'results', locals: {title: "Movies released in #{search_query}"}
  end

  # Search by director
  # return list of movies (title + id) based on director
  def director
    #movie_dir = 'Stanley Kubrik'
    # @movie_dir = params[:movie_dir] # in order to be available in the view
    q = %Q(
      SELECT ?id ?title ?directorName ?releaseDate
      WHERE {
        ?movies rdf:type movie:film .
        ?movies rdfs:label ?title .
        ?d rdf:type movie:director .
        ?movies movie:director ?d .
        ?d movie:director_name ?directorName .
        FILTER regex(?directorName, '^.*#{search_query(true)}', 'i')
        ?movies movie:initial_release_date ?releaseDate .
        ?movies movie:filmid ?id .
      }
      ORDER BY ?title
    )
    res = RemoteData.linkedmdb_query(q)
    @movies = res[:results][:bindings].each do |movie|
      movie[:matching_value] = movie[:directorName][:value]
    end
    render 'results', locals: {title: "Movies whose director's name contains #{search_query}'"}
  end

  private

  def search_query(escape=false)
    if escape
      # This is not safe! We just want to allow the user to enter single quotes
      # without the search failing.
      params[:query].gsub("'"){"\\'"}
    else
      params[:query]
    end
  end
end
