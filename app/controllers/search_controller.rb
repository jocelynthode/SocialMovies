class SearchController < ApplicationController
  def index
    graph = RDF::Graph.load("http://ruby-rdf.github.com/rdf/etc/doap.nt")
    query = RDF::Query.new({
      person: {
        RDF.type  => RDF::Vocab::FOAF.Person,
        RDF::Vocab::FOAF.name => :name,
        RDF::Vocab::FOAF.mbox => :email,
      }
    })

    query.execute(graph) do |solution|
      puts "name=#{solution.name} email=#{solution.email}"
    end

    sparql = SPARQL::Client.new("http://data.linkedmdb.org/sparql")
    query = sparql.select.where([:s, :p, :o]).offset(100).limit(10)

    query.each_solution do |solution|
      puts solution.inspect
    end
  end
end
