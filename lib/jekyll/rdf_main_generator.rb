##
# MIT License
#
# Copyright (c) 2016 Elias Saalmann, Christian Frommert, Simon Jakobi,
# Arne Jonas Präger, Maxi Bornmann, Georg Hackel, Eric Füg
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

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
      begin
        config = site.config.fetch('jekyll_rdf')
      rescue Exception
        Jekyll.logger.error("You've included Jekyll-RDF, but it is not configured. Aborting the jekyll-rdf plugin.")
        return
      end
      if(config.key? "template_mapping")
        Jekyll.logger.error("Outdated format in _config.yml:\n  'template_mapping' detected but the following keys must be used now instead:\n    instance_template_mappings -> maps single resources to single layouts\n    class_template_mappings -> maps entire classes of resources to layouts\nJekyll-RDF wont render any pages for #{site.source}")
        return
      end

      graph = RDF::Graph.load(config['path'])
      sparql = SPARQL::Client.new(graph)

      # restrict RDF graph with restriction
      resources = extract_resources(config['restriction'], config['include_blank'], graph, sparql)

      site.data['sparql'] = sparql
      site.data['resources'] = []

      #parse resources
      pageResources={};
      blanknodes=[]
      resources.each do |uri|
        resource = Jekyll::Drops::RdfResource.new(uri, graph)
        if(uri.instance_of? RDF::URI)
          uriString = uri.to_s
          if((uriString.include? "#") && (uriString.index("#") < (uriString.length - 1)))   #sorting in uris with a #
            preSufUri = uriString.split("#")
            if(!pageResources.key? preSufUri[0])
              pageResources[preSufUri[0]] = {}
            end
            pageResources[preSufUri[0]][preSufUri[1]] = resource
          elsif                                  #sorting in uris without a #
            if(!pageResources.key? uriString)
              pageResources[uriString]={}
            end
            pageResources[uriString]['./'] = resource
          end
        elsif(uri.instance_of? RDF::Node)
          blanknodes << resource
        end
      end

      mapper = Jekyll::RdfTemplateMapper.new(config['instance_template_mappings'], config['class_template_mappings'], config['default_template'], graph, sparql)

      # create RDF pages for each URI
      pageResources.each{|uri, entry|
        if(entry['./'].nil?)
          if(config['render_orphaned_uris'])
            entry.each{|name, resource|
              site.pages << RdfPageData.new(site, site.source, resource, mapper)
            }
          end
        else
          resource = entry.delete('./')
          resource.subResources = entry
          site.pages << RdfPageData.new(site, site.source, resource, mapper)
        end
      }

      blanknodes.each{|resource|
        site.pages << RdfPageData.new(site, site.source, resource, mapper)
      }
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
        sparql.query(selection).map{ |sol| sol[:resourceUri] }
      end.reject do |s|  # Reject literals
        s.class <= RDF::Literal
      end.select do |s|  # Select URIs and blank nodes in case of include_blank
        include_blank || s.class == RDF::URI
      end.uniq
    end

  end

end
