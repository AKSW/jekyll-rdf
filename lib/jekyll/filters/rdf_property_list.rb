module Jekyll

  ##
  # Internal module to hold the method #rdf_property
  #
  module RdfPropertyList

    ##
    # Computes all objects for which statements exist containing the given subject and predicate and returns an Array of them
    #
    # * +input+ - is the subject of the statements to be matched
    # * +predicate+ - is the predicate of the statements to be matched
    # * +lang+ - (optional) preferred language of the returned objects. If 'cfg' is specified the preferred language is provides by the site configuration _config.yml
    #
    def rdf_property_list(input, predicate, lang = nil)
      return input unless input.is_a?(Jekyll::Drops::RdfResource)
      begin
        result = input.page.data['rdf'].statements_as_subject.select{ |s| s.predicate.term.to_s == predicate } # select all matching statements with given predicate
        if lang != nil
          if lang == 'cfg'
            lang ||= input.site.config['language']
          end
          result = result.select{ |s| s.object.term.language == lang.to_sym } # select all statements with matching language
        end
        return unless result
        result.map{|p| p.object.name}
      end
    end

  end
end

Liquid::Template.register_filter(Jekyll::RdfPropertyList)
