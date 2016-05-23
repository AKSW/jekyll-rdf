module Jekyll
  module RdfProperty

    def rdf_property(input, predicate)
      return input unless input.is_a?(Jekyll::Drops::RdfResource)
      begin
        result = input.page.data['rdf'].statements_as_subject.select{ |s| s.predicate.term.to_s == predicate }
        p = result.first unless p
        return unless p
        (p.object.name).to_s
      end
    end

  end
end

Liquid::Template.register_filter(Jekyll::RdfProperty)
