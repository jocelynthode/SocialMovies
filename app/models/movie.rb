class Movie < ActiveRecord::Base
  has_and_belongs_to_many :lists
  attr_accessor :title, :releaseDate, :actors, :imdb

  # TODO: put everything in one place
  RDF_PREFIXES = '
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
    PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
    PREFIX foaf: <http://xmlns.com/foaf/0.1/>'
  RDF_ENDPOINT = 'http://data.linkedmdb.org/sparql'

  # Retrieve movie model from datastore and add entry in local DB
  def self.retrieve(mid)
    sparql = SPARQL::Client.new(RDF_ENDPOINT)
    q = %Q(
      #{RDF_PREFIXES}
      SELECT ?id ?title ?releaseDate ?imdb ?actorName
      WHERE {
        ?movies rdf:type movie:film .
        ?movies movie:filmid "#{mid}"^^xsd:int .
        ?movies rdfs:label ?title .
        ?movies movie:initial_release_date ?releaseDate .
        ?movies foaf:page ?imdb .
        FILTER regex(str(?imdb), '^http://www.imdb.com/title/')
        OPTIONAL {
          ?movies movie:filmid "#{mid}"^^xsd:int .
          ?movies movie:actor ?a .
          ?a rdf:type movie:actor .
          ?a movie:actor_name ?actorName
        }
      }
    )
    res = sparql.query(q)
    return nil if res.empty?

    movie = Movie.find_or_create_by(id: mid)
    movie.title = res[0][:title].value
    movie.releaseDate = res[0][:releaseDate].value
    movie.imdb = res[0][:imdb].value.split('/').last
    movie.actors = res.map{|x| x[:actorName]}.compact.map(&:value)
    movie
  end

  # Populate current instance with info from datastore
  def retrieve!
    raise %q('id' cannot be null) if not self.id
    res = self.class.retrieve(self.id)
    self.title = res.title
    self.releaseDate = res.releaseDate
    self.actors = res.actors
    self.imdb = res.imdb
    self
  end
end
