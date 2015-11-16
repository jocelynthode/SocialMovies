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
  end
end
