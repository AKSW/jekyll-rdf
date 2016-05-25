module Jekyll
  
  ##
  # Internal module to hold the medthod #rdf_property
  #
  module RdfPropertyList

    ##
    # Computes all objects for which statements exist containing the given subject and predicate and returns an Array of them
    #
    # * +input+ - is the subject of the statements to be matched
    # * +property+ - is the predicate of the statements to be matched
    #
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
