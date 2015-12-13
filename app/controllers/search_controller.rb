class SearchController < ApplicationController
  skip_before_action :authenticate_user!

  def index
  end


  # Search by actor name
  # return list of movies (title + id) based on actor
  def actor
    #actor_name = 'Jack Nicholson'
    # @actor_name = params[:actor_name] # in order to be available in the view
    bindings = search_query([:actorName], %[
      ?movies movie:actor ?a .
      ?a rdf:type movie:actor .
      ?a movie:actor_name ?actorName .
      FILTER regex(?actorName, '^.*#{query_param(true)}', 'i')
    ])
    @movies = bindings.each do |movie|
      movie[:matching_value] = movie[:actorName][:value]
    end
    render 'results', locals: {title: "Movies with one of the actor name containing '#{query_param}'"}
  end

  # Search by movie name
  # return list of movies (title + id) based on movie name
  def movie
    #movie_name = 'Batman'
    # @movie_name = params[:movie_name] # in order to be available in the view
    @movies = search_query([], %[
      FILTER regex(?title, '^.*#{query_param(true)}', 'i')
    ])
    render 'results', locals: {title: "Movies with title containing '#{query_param}'"}
  end

  # Search by year
  # return list of movies (title + id) based on year
  def year
    #movie_year = '2014'
    # @movie_year = params[:movie_year] # in order to be available in the view
    @movies = search_query([], %[
      FILTER regex(?releaseDate, '^#{query_param(true)}')
    ])
    render 'results', locals: {title: "Movies released in #{query_param}"}
  end

  # Search by director
  # return list of movies (title + id) based on director
  def director
    #movie_dir = 'Stanley Kubrik'
    # @movie_dir = params[:movie_dir] # in order to be available in the view
    bindings = search_query([:directorName], %[
      ?d rdf:type movie:director .
      ?movies movie:director ?d .
      ?d movie:director_name ?directorName .
      FILTER regex(?directorName, '^.*#{query_param(true)}', 'i')
    ])
    @movies = bindings.each do |movie|
      movie[:matching_value] = movie[:directorName][:value]
    end
    render 'results', locals: {title: "Movies whose director's name contains '#{query_param}'"}
  end

  private

  # Try to factorize everything common in each search request
  def search_query(output_vars, predicates)
    variables = output_vars.map do |var|
      (var.is_a? Symbol) ? var.to_s.prepend('?') : var
    end
    q = %Q(
      SELECT ?id ?title ?releaseDate ?imdb #{variables.join(' ')}
      WHERE {
        ?movies rdf:type movie:film .
        ?movies movie:filmid ?id .
        ?movies rdfs:label ?title .
        ?movies movie:initial_release_date ?releaseDate .
        #{predicates}
        ?movies foaf:page ?imdb .
        FILTER regex(str(?imdb), '^http://www.imdb.com/title/')
      }
      ORDER BY ?title
    )
    res = RemoteData.linkedmdb_query(q)
    bindings = res[:results][:bindings]
    bindings.each do |movie|
      movie[:imdb_id] = movie[:imdb][:value].split('/').last
    end
    bindings
  end

  def query_param(escape=false)
    if escape
      # This is not safe! We just want to allow the user to enter single quotes
      # without the search failing.
      params[:query].gsub("'"){"\\'"}
    else
      params[:query]
    end
  end
end
