class Movie < ActiveRecord::Base
  has_and_belongs_to_many :lists
  attr_accessor :title, :releaseDate, :actors

  # TODO: put everything in one place
  RDF_PREFIXES = '
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
    PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>'
  RDF_ENDPOINT = 'http://data.linkedmdb.org/sparql'

  # Retrieve movie model from datastore and add entry in local DB
  def self.retrieve(mid)
    sparql = SPARQL::Client.new(RDF_ENDPOINT)
    q = %Q(
      #{RDF_PREFIXES}
      SELECT ?id ?title ?releaseDate ?actorName
      WHERE {
        ?movies rdf:type movie:film .
        ?movies movie:filmid "#{mid}"^^xsd:int .
        ?movies rdfs:label ?title .
        ?movies movie:initial_release_date ?releaseDate .
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
    movie.actors = res.map{|x| x[:actorName]}.compact.map(&:value)
    movie
  end
end