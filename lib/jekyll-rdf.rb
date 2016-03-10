require 'linkeddata'
require 'sparql'

module JekyllRdf
  class Generator < Jekyll::Generator
    safe true
    priority :highest

    def generate(site)
      config = site.config['jekyll_rdf']
      return unless config

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
