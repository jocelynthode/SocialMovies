class SearchController < ApplicationController

  # SPARQL Prefixes
  $p_rdfs = "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>"
  $p_rdf = "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
  $p_movie = "PREFIX movie: <http://data.linkedmdb.org/resource/movie/>"
  $endpoint = "http://data.linkedmdb.org/sparql"

  def index
    # graph = RDF::Graph.load("http://ruby-rdf.github.com/rdf/etc/doap.nt")
    # query = RDF::Query.new({
    #   person: {
    #     RDF.type  => RDF::Vocab::FOAF.Person,
    #     RDF::Vocab::FOAF.name => :name,
    #     RDF::Vocab::FOAF.mbox => :email,
    #   }
    # })
    #
    # query.execute(graph) do |solution|
    #   puts "name=#{solution.name} email=#{solution.email}"
    # end

    ## this works
    # repo = SPARQL::Client::Repository.new("http://dbpedia.org/sparql")
    # puts repo.count
    ##

    # TODO: remove this query (only there for quick testing)
    movie_name = "Batman"
    #movie_name = 'Batman'
    # @movie_name = params[:movie_name] # in order to be available in the view
    sparql = SPARQL::Client.new($endpoint)
    q = $p_rdfs + ' ' + $p_movie  + ' ' + $p_rdf + '
      SELECT ?mname ?movies
      WHERE {
        ?movies rdf:type movie:film .
        ?movies rdfs:label ?mname .
        FILTER regex(?mname, \'^.*' +movie_name+ '\', \'i\') .}
        ORDER BY ?mname'
    res = sparql.query(q)

    res.each_solution do |solution|
      puts solution.inspect
    end

  end


  # Search by actor name
  # return list of movies (title + id) based on actor
  def actor
    actor_name = params[:actor_name]
    #actor_name = 'Jack Nicholson'
    # @actor_name = params[:actor_name] # in order to be available in the view
    sparql = SPARQL::Client.new($endpoint)
    q = $p_rdfs + ' ' + $p_movie  + ' ' + $p_rdf + '
      SELECT ?mname ?movies
      WHERE {
        ?movies rdf:type movie:film .
        ?movies rdfs:label ?mname .
        ?movies movie:actor ?a .
        ?a movie:actor_name \'' +actor_name+ '\' .}
        ORDER BY ?mname'
    res = sparql.query(q)

    res.each_solution do |solution|
      puts solution.inspect
    end
  end

  # Search by movie name
  # return list of movies (title + id) based on movie name
  def movie
    movie_name = params[:movie_name]
    #movie_name = 'Batman'
    # @movie_name = params[:movie_name] # in order to be available in the view
    sparql = SPARQL::Client.new($endpoint)
    q = $p_rdfs + ' ' + $p_movie  + ' ' + $p_rdf + '
      SELECT ?mname ?movies
      WHERE {
        ?movies rdf:type movie:film .
        ?movies rdfs:label ?mname .
        FILTER regex(?mname, \'^.*' +movie_name+ '\', \'i\') .}
        ORDER BY ?mname'
    res = sparql.query(q)

    res.each_solution do |solution|
      puts solution.inspect
    end
  end

  # Search by year
  # return list of movies (title + id) based on year
  def year
    movie_year = params[:movie_year]
    #movie_year = '2014'
    # @movie_year = params[:movie_year] # in order to be available in the view
    sparql = SPARQL::Client.new($endpoint)
    q = $p_rdfs + ' ' + $p_movie  + ' ' + $p_rdf + '
      SELECT ?mname ?movies
      WHERE {
        ?movies rdf:type movie:film .
        ?movies rdfs:label ?mname .
        ?movies movie:initial_release_date ?d .
        FILTER regex(?d, \'^' +movie_year+ '\') .}
        ORDER BY ?mname'
    res = sparql.query(q)

    res.each_solution do |solution|
      puts solution.inspect
    end
  end

  # Search by director
  # return list of movies (title + id) based on director
  def director
    movie_dir = params[:movie_dir]
    #movie_dir = 'Stanley Kubrik'
    # @movie_dir = params[:movie_dir] # in order to be available in the view
    sparql = SPARQL::Client.new($endpoint)
    q = $p_rdfs + ' ' + $p_movie  + ' ' + $p_rdf + '
      SELECT ?mname ?movies
      WHERE {
        ?movies rdf:type movie:film .
        ?movies rdfs:label ?mname .
        ?d rdf:type movie:director .
        ?movies movie:director ?d .
        ?d movie:director_name ?dname .
        FILTER regex(?dname, \'^.*' +movie_dir+ '\', \'i\') .}
        ORDER BY ?mname'
    res = sparql.query(q)

    res.each_solution do |solution|
      puts solution.inspect
    end
  end

end
