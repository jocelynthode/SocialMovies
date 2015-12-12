class RemoteData

  RDF_PREFIXES = '
    PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
    PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
    PREFIX movie: <http://data.linkedmdb.org/resource/movie/>
    PREFIX xsd: <http://www.w3.org/2001/XMLSchema#>
    PREFIX foaf: <http://xmlns.com/foaf/0.1/>'

  RDF_ENDPOINT = 'http://data.linkedmdb.org/sparql'

  def self.linkedmdb_query(query, endpoint: RDF_ENDPOINT, prefixes: RDF_PREFIXES)
    redis_key = 'sparql_' + Digest::SHA1.hexdigest(endpoint + prefixes + query)
    response = redis.get(redis_key)
    unless response
      sparql = SPARQL::Client.new(endpoint)
      response = sparql.query(prefixes + query).to_json
    end
    JSON.parse(response, symbolize_names: true)
  end

  def self.omdb_query(imdb_id)
    redis_key = 'omdb_' + imdb_id
    response = redis.get(redis_key)
    unless response
      response = HTTP.get('http://www.omdbapi.com/', params: {
          i: imdb_id,
          plot: 'full',
          r: 'json'
      })
      redis.set(redis_key, response.to_s)
    end

    data = JSON.parse(response, symbolize_names: true)
    status = data[:Error] ? false : true
    [status, data]
  end


  protected

  def self.redis
    if @redis
      @redis
    else
      @redis = Redis.new
    end
  end

end