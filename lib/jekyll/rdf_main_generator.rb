module Jekyll

  ##
  #
  # JekyllRdf::Generator enriches site.data with rdf triples
  #
  class RdfMainGenerator < Jekyll::Generator
    safe true
    priority :highest

    ##
    # #generate performs the enrichment of site.data with rdf triples
    #
    # * +site+ - The site whose data is to be enriched
    #
    def generate(site)
      config = site.config.fetch('jekyll_rdf')

      graph = RDF::Graph.load(config['path'])
      sparql = SPARQL::Client.new(graph)

      resources = extract_resources(config['restriction'], graph, sparql)

      resources.each do |resource|
        site.pages << RdfPageData.new(site, site.source, resource, graph)
      end
    end

    def extract_resources(restriction, graph, sparql)
      # Reject literals and null values
      object_resources = graph.objects.select { |o| o.class == RDF::URI }.uniq
      subject_resources = graph.subjects.select { |s| s.class == RDF::URI }.uniq
      predicate_resources = graph.predicates.select { |p| p.class == RDF::URI }.uniq

      # Config parameter not present
      unless restriction
        return object_resources.concat(subject_resources).concat(predicate_resources)
      end

      case restriction
      when "objects"
        return object_resources
      when "subjects"
        return subject_resources
      when "predicates"
        return predicate_resources
      else
        # Custom query
        result = sparql.query(restriction).map{|sol| sol.each_value.first}
        return result.select { |s| s.class == RDF::URI }.uniq
      end
      []
    end

  end

end
