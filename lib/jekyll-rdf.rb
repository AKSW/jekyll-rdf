require 'linkeddata'
require 'sparql'

##
# JekyllRdf converts RDF data into static websites
#
# 
module JekyllRdf
  ##
  #
  # JekyllRdf::Generator enriches site.data with rdf triples
  #
  class Generator < Jekyll::Generator
    safe true
    priority :highest

    ##
    # #generate performs the enrichment of site.data with rdf triples
    #
    def generate(site)
      config = site.config.fetch('jekyll_rdf')

      queryable = RDF::Repository.load(config['path'], format: :ttl)
      site.data['rdf'] = queryable.statements.map do |statement|
        [
          statement.subject.to_s,
          statement.predicate.to_s,
          statement.object.to_s
        ]
      end
    end
  end
end
