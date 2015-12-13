class Movie < ActiveRecord::Base
  has_and_belongs_to_many :lists
  attr_accessor :title, :release_date, :actors, :imdb


  # Retrieve movie model from datastore and add entry in local DB
  def self.retrieve(mid)
    q = %Q(
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
    res = RemoteData.linkedmdb_query(q)
    bindings = res[:results][:bindings]
    return nil if bindings.empty?

    movie = Movie.find_or_create_by(id: mid)
    movie.title = bindings[0][:title][:value]
    movie.release_date = bindings[0][:releaseDate][:value]
    movie.imdb = bindings[0][:imdb][:value].split('/').last
    movie.actors = bindings.map{|x| x[:actorName]}.compact.map{|x| x[:value]}
    movie
  end

  # Populate current instance with info from datastore
  def retrieve!
    raise %q('id' cannot be null) if not self.id
    res = self.class.retrieve(self.id)
    self.title = res.title
    self.release_date = res.release_date
    self.actors = res.actors
    self.imdb = res.imdb
    self
  end
end
