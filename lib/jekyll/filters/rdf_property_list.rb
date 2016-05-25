module Jekyll
  
  ##
  # Internal module to hold the medthod #rdf_property
  #
  module RdfPropertyList

    def rdf_property_list(input, property)
      return input unless input.is_a?(Jekyll::Drops::RdfResource)
      begin
        result = input.page.data['rdf'].statements_as_subject.select{ |s| s.predicate.term.to_s == property }.map{|p| p.object.name}
        return unless result
        result
      end
    end

  end
end

Liquid::Template.register_filter(Jekyll::RdfPropertyList)
