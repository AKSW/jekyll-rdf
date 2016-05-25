module Jekyll
  module RdfProperty

    def rdf_property(input, params)
      return input unless input.is_a?(Jekyll::Drops::RdfResource)
      begin
        params = params.split(",")
        results = input.page.data['rdf'].statements_as_subject.select{ |s| s.predicate.term.to_s == params[0] }
        lang = params[1] || input.site.config['language']
        if results.count > 1 && results.first.object.term.is_a?(RDF::Term)
          p = results.find{ |s| s.object.term.language == lang }
        end
        p = results.first unless p
        return unless p
        (p.object.name).to_s
      end
    end

  end
end

Liquid::Template.register_filter(Jekyll::RdfProperty)
