module Jekyll
    
  ##
  # Internal module to hold the medthod #sparql_query
  #
  module RdfSparqlQuery

    ##
    # Executes a SPARQL query. The supplied query is augmented by replacing each occurence of '?resourceUri' by the URI of the context RDF resource.
    # Returns an Array of bindings. Each binding is a Hash mapping variables to their values.
    #
    # * +input+ - the context RDF resource
    # * +query+ - the SPARQL query
    #
    def sparql_query(input, query)
      return input unless input.is_a?(Jekyll::Drops::RdfResource)
      query.gsub!('?resourceUri', "<#{input.term.to_s}>")
      begin
        result = input.site.data['sparql'].query(query).map do |solution|
          hsh = solution.to_hash
          hsh.update(hsh){ |k,v| Jekyll::Drops::RdfTerm.build_term_drop(v, input.graph, input.site) }
          hsh.collect{|k,v| [k.to_s, v]}.to_h
        end
        return result
      end
    end

  end
end

Liquid::Template.register_filter(Jekyll::RdfSparqlQuery)
