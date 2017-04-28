module Jekyll
  module RdfCollection
    def rdf_collection(input)
      if(input.statements_as_subject.any?{ |statement|
        statement.predicate.to_s.eql? "http://www.w3.org/1999/02/22-rdf-syntax-ns#rest"
      })
        finalizedContainer = Set.new #avoid loops
        nodeSequence = [input.iri]
        nextSequence = []
        results = []
        sparqlClient = input.site.data['sparql']
        while(!nodeSequence.empty?)
          currentContainer = nodeSequence.pop
          query = "SELECT ?f ?r WHERE{ <#{currentContainer}> <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest> ?r. <#{currentContainer}> <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> ?f}"
          solutions = sparqlClient.query(query).each { |solution|
            if((!solution.r.to_s.eql? "http://www.w3.org/1999/02/22-rdf-syntax-ns#nil") && (finalizedContainer.add? solution.r))
              nextSequence.push solution.r.to_s
            end
            results.push Jekyll::Drops::RdfTerm.build_term_drop(solution.f, input.graph, input.site)
            if(nodeSequence.empty?)
              nodeSequence = nextSequence
              nextSequence = []
            end
          }
          end
        return results
      end
    end
  end
end

Liquid::Template.register_filter(Jekyll::RdfCollection)
