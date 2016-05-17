module Jekyll
  module RdfSparqlQuery

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
      rescue
        []
      end
    end

  end
end

Liquid::Template.register_filter(Jekyll::RdfSparqlQuery)
