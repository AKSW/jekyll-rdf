require 'linkeddata'
require 'sparql'

module JekyllRdf

  class Generator < Jekyll::Generator
      safe true
      priority :highest

      def generate(site)
        config = site.config['jekyll_rdf']
        if !config
          return
        end

        queryable = RDF::Repository.load(config['path'], format: :ttl)
        site.data['rdf'] = []
        queryable.statements.each do |statement|
          site.data['rdf'] << [
            statement.subject.to_s,
            statement.predicate.to_s,
            statement.object.to_s
          ]
        end
      end

   end

end
