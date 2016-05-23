module Jekyll

  ##
  #
  # Jekyll::RdfMainGenerator enriches a Jekyll::Site with RDF triples
  #
  class RdfMainGenerator < Jekyll::Generator
    safe true
    priority :highest

    ##
    # #generate performs the enrichment of a Jekyll::Site with rdf triples
    #
    # * +site+ - The Jekyll::Site whose #data is to be enriched
    #
    def generate(site)
      config = site.config.fetch('jekyll_rdf')

      graph = RDF::Graph.load(config['path'])
      sparql = SPARQL::Client.new(graph)

      # restrict RDF graph with restriction
      resources = extract_resources(config['restriction'], config['include_blank'], graph, sparql)

      site.data['resources'] = []
      site.data['domain_name'] = URI::split(site.config['url'])[2]

      mapper = Jekyll::RdfTemplateMapper.new(config['template_mappings'], config['default_template'])

      # create RDF pages for each URI
      resources.each do |uri|
        resource = Jekyll::Drops::RdfResource.new(uri, graph)
        site.pages << RdfPageData.new(site, site.source, resource, mapper)
      end
    end

    ##
    # #extract_resources returns resources from an RDF graph.
    # 
    # Literals are omitted.
    # Blank nodes are only returned if +include_blank+ is true.
    # Duplicate nodes are removed.
    #
    # * +selection+ - choose any of the following:
    #   nil ::
    #     no restrictions, return subjects, predicates, objects 
    #   "subjects" ::
    #     return only subjects
    #   "predicates" ::
    #     return only predicates
    #   "objects" ::
    #     return only objects
    #   Otherwise ::
    #     consider +selection+ to be a SPARQL query and return answer set to this SPARQL query
    # * +include_blank+ - If true, blank nodes are also returned, otherwise blank nodes are omitted
    # * +graph+ - The RDF graph to restrict
    # * +sparql+ - The SPARQL client to run queries against
    #
    def extract_resources(selection, include_blank, graph, sparql)

      case selection
      when nil  # Config parameter not present
        object_resources    = extract_resources("objects",    include_blank, graph, sparql)
        subject_resources   = extract_resources("subjects",   include_blank, graph, sparql)
        predicate_resources = extract_resources("predicates", include_blank, graph, sparql)
        return object_resources.concat(subject_resources).concat(predicate_resources).uniq      
      when "objects"
        graph.objects
      when "subjects"
        graph.subjects
      when "predicates"
        graph.predicates
      else
        # Custom query
        sparql.query(selection).map{|sol| sol.each_value.first}
      end.reject do |s|  # Reject literals
        s.class <= RDF::Literal 
      end.select do |s|  # Select URIs and blank nodes in case of include_blank
        include_blank || s.class == RDF::URI 
      end.uniq
    end

  end

end
