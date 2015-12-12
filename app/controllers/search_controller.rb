class SearchController < ApplicationController
  skip_before_action :authenticate_user!

  # SPARQL Prefixes
  $p_rdfs = "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>"
  $p_rdf = "PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>"
  $p_movie = "PREFIX movie: <http://data.linkedmdb.org/resource/movie/>"
  $prefixes = "PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX dbo: <http://dbpedia.org/ontology/>
    PREFIX dbp: <http://dbpedia.org/property/>
    PREFIX dcterms: <http://purl.org/dc/terms/>"
  $endpoint = "http://data.linkedmdb.org/sparql"
  # $endpoint = "http://dbpedia.org/sparql"

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
  end


  # Search by actor name
  # return list of movies (title + id) based on actor
  def actor
    actor_name = params[:actor_name]
    #actor_name = 'Jack Nicholson'
    # @actor_name = params[:actor_name] # in order to be available in the view
    sparql = SPARQL::Client.new($endpoint)
    q = $p_rdfs + ' ' + $p_movie  + ' ' + $p_rdf + '
      SELECT ?id ?title ?actorName ?releaseDate
      WHERE {
        ?a rdf:type movie:actor .
        ?a movie:actor_name ?actorName .
        FILTER regex(?actorName, \'^.*' +actor_name+ '\', \'i\')
        ?movies rdf:type movie:film .
        ?movies rdfs:label ?title .
        ?movies movie:actor ?a .
        ?movies movie:filmid ?id .
        ?movies movie:initial_release_date ?releaseDate .
      }
      ORDER BY ?title'
    res = sparql.query(q)
    hash_res = JSON.parse(res.to_json)
    @movies = hash_res['results']['bindings']
    puts '#### =========== ####'
    puts @movies
    puts '#### =========== ####'
  end

  # Search by movie name
  # return list of movies (title + id) based on movie name
  def movie
    movie_name = params[:movie_name]
    #movie_name = 'Batman'
    # @movie_name = params[:movie_name] # in order to be available in the view
    sparql = SPARQL::Client.new($endpoint)
    q = $p_rdfs + ' ' + $p_movie  + ' ' + $p_rdf + '
      SELECT ?id ?title ?releaseDate
      WHERE {
        ?movies rdf:type movie:film .
        ?movies rdfs:label ?title .
        FILTER regex(?title, \'^.*' +movie_name+ '\', \'i\')
        ?movies movie:filmid ?id .
        ?movies movie:initial_release_date ?releaseDate .
      }
      ORDER BY ?title'
    # q = $prefixes + '
    # SELECT DISTINCT ?title ?abstract (str(sample(?movie_year)) as ?releaseDate)
    # WHERE {
    #   ?mres rdf:type dbo:Film .
    #   ?mres rdfs:label ?title .
    #   FILTER langMatches(lang(?abstract),"en")
    #   FILTER langMatches(lang(?title),"en")
    #   FILTER regex(?title, "^.*' +movie_name+ '", "i")
    #   OPTIONAL { ?mres rdfs:comment ?abstract . }
    #   OPTIONAL { ?mres dbp:released ?rel_year . }
    #   OPTIONAL { ?mres dbo:releaseDate ?owl_year .}
    #   OPTIONAL { ?mres dcterms:subject ?sub .
    #              ?sub rdfs:label ?movie_year_sub .
    #              filter regex(?movie_year_sub, ".*[0-9]{4}.*", "i")
    #            }
    #   BIND(COALESCE(?owl_year, ?rel_year, ?movie_year_sub) AS ?movie_year)
    # }
    # GROUP BY ?title ?abstract
    # ORDER BY ?title'
    # puts '#### ----------------'
    # puts q
    # puts '#### ----------------'
    res = sparql.query(q)
    hash_res = JSON.parse(res.to_json)
    @movies = hash_res['results']['bindings']
    puts '#### =========== ####'
    puts @movies
    puts '#### =========== ####'
  end

  # Search by year
  # return list of movies (title + id) based on year
  def year
    movie_year = params[:movie_year]
    #movie_year = '2014'
    # @movie_year = params[:movie_year] # in order to be available in the view
    sparql = SPARQL::Client.new($endpoint)
    q = $p_rdfs + ' ' + $p_movie  + ' ' + $p_rdf + '
      SELECT ?id ?title ?releaseDate
      WHERE {
        ?movies rdf:type movie:film .
        ?movies rdfs:label ?title .
        ?movies movie:initial_release_date ?releaseDate .
        FILTER regex(?releaseDate, \'^' +movie_year+ '\')
        ?movies movie:filmid ?id .
      }
      ORDER BY ?title'
    res = sparql.query(q)
    hash_res = JSON.parse(res.to_json)
    @movies = hash_res['results']['bindings']
    puts '#### =========== ####'
    puts @movies
    puts '#### =========== ####'
  end

  # Search by director
  # return list of movies (title + id) based on director
  def director
    movie_dir = params[:movie_dir]
    #movie_dir = 'Stanley Kubrik'
    # @movie_dir = params[:movie_dir] # in order to be available in the view
    sparql = SPARQL::Client.new($endpoint)
    q = $p_rdfs + ' ' + $p_movie  + ' ' + $p_rdf + '
      SELECT ?id ?title ?directorName ?releaseDate
      WHERE {
        ?movies rdf:type movie:film .
        ?movies rdfs:label ?title .
        ?d rdf:type movie:director .
        ?movies movie:director ?d .
        ?d movie:director_name ?directorName .
        FILTER regex(?directorName, \'^.*' +movie_dir+ '\', \'i\')
        ?movies movie:initial_release_date ?releaseDate .
        ?movies movie:filmid ?id .
      }
      ORDER BY ?title'
    res = sparql.query(q)
    hash_res = JSON.parse(res.to_json)
    @movies = hash_res['results']['bindings']
    puts '#### =========== ####'
    puts @movies
    puts '#### =========== ####'
  end

end
