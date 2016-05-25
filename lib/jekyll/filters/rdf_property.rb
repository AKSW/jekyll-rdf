module Jekyll
  
  ##
  # Internal module to hold the medthod #rdf_property
  #
  module RdfProperty
  	  
    ##
    # Computes all objects for which statements exist containing the given subject and predicate and returns any of them
    #
    # * +input+ - is the subject of the statements to be matched
    # * +predicate+ - is the predicate of the statements to be matched
    # * +lang+ - (optional) preferred language of a the returned object. The precise implementation of choosing which object to returned (both in case a language is supplied and in case is not supplied) is undefined
    #
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
