module Jekyll
  module RdfProperty

    def rdf_property(input, predicate, lang = nil)
      return input unless input.is_a?(Jekyll::Drops::RdfResource)
      begin
        results = input.page.data['rdf'].statements_as_subject.select{ |s| s.predicate.term.to_s == predicate }
        lang ||= input.site.config['language']
        if results.count > 1 && results.first.object.term.is_a?(RDF::Term) && lang != nil
          p = results.find{ |s| s.object.term.language == lang.to_sym }
        end
        p = results.first unless p
        return unless p
        (p.object.name).to_s
      end
    end

  end
end

Liquid::Template.register_filter(Jekyll::RdfProperty)
