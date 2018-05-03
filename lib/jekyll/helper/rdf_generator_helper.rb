module Jekyll
  module JekyllRdf
    module Helper
      module RdfGeneratorHelper
        private
        def prepare_pages (site, mapper)
          @pageResources.each{|uri, entry|
            resource = entry.delete('./')
            resource.subResources = entry
            create_page(site, resource, mapper, @global_config)
          }

          @blanknodes.each{|resource|
            create_page(site, resource, mapper, @global_config)
          }
        end

        def parse_resources (resources)
          @pageResources={};
          @blanknodes=[]
          resources.each do |uri|
            resource = Jekyll::JekyllRdf::Drops::RdfResource.new(uri, nil, nil, true)
            if(uri.instance_of? RDF::URI)
              uriString = uri.to_s
              if((uriString.include? "#") && (uriString.index("#") < (uriString.length - 1)))   #sorting in uris with a #
                preSufUri = uriString.split("#")
                if(!@pageResources.key? preSufUri[0])
                  @pageResources[preSufUri[0]] = {}
                end
                @pageResources[preSufUri[0]][preSufUri[1]] = resource
              else                                  #sorting in uris without a #
                if(!@pageResources.key? uriString)
                  @pageResources[uriString]={}
                end
                @pageResources[uriString]['./'] = resource
              end
            elsif(uri.instance_of? RDF::Node)
              @blanknodes << resource
            end
          end
          # give parents to orphaned resources
          @pageResources.each_key{|key|
            @pageResources[key]['./'] = Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI(key)) if @pageResources[key]['./'].nil?
          }
        end

        def load_config (site)
          begin
            @config = site.config.fetch('jekyll_rdf')
          rescue KeyError => e
            Jekyll.logger.error("You've included Jekyll-RDF, but it is not configured. Aborting the jekyll-rdf plugin.")
            return false
          end

          @global_config = Jekyll.configuration({})
          #small fix because global_config doesn't work in a test enviorment
          if(!@global_config.key? "url")
            @global_config["url"] = site.config["url"]
            @global_config["baseurl"] = site.config["baseurl"]
          end

          if(@config["baseiri"].nil?)
            Jekyll::JekyllRdf::Helper::RdfHelper::domainiri = @global_config["url"]
            Jekyll::JekyllRdf::Helper::RdfHelper::pathiri = @global_config["baseurl"]
          else
            uri = Addressable::URI.parse(@config["baseiri"]).to_hash
            domainuri = ""
            domainuri << "#{uri[:scheme]}://" unless uri[:scheme].nil?
            domainuri << "#{uri[:userinfo]}@" unless uri[:userinfo].nil?
            domainuri << "#{uri[:host]}" unless uri[:host].nil?
            domainuri << ":#{uri[:port]}" unless uri[:port].nil?
            Jekyll::JekyllRdf::Helper::RdfHelper::domainiri = domainuri
            Jekyll::JekyllRdf::Helper::RdfHelper::pathiri = uri[:path][0..-1].to_s unless uri[:path].nil?
          end
          return true
        end
        ##
        # #extract_resources returns resources from an RDF Sparql endpoint.
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
        # * +sparql+ - The SPARQL client to run queries against
        #
        def extract_resources(selection, include_blank, sparql)

          case selection
          when nil  # Config parameter not present
            object_resources    = extract_resources("objects",    include_blank, sparql)
            subject_resources   = extract_resources("subjects",   include_blank, sparql)
            predicate_resources = extract_resources("predicates", include_blank, sparql)
            return object_resources.concat(subject_resources).concat(predicate_resources).uniq
          when "objects"
            query = "SELECT ?resourceUri WHERE{?s ?p ?resourceUri}"
          when "subjects"
            query = "SELECT ?resourceUri WHERE{?resourceUri ?p ?o}"
          when "predicates"
            query = "SELECT ?resourceUri WHERE{?s ?resourceUri ?o}"
          else
            # Custom query
            query = selection
          end
          sparql.query(query).map{ |sol| sol[:resourceUri] }.reject do |s|  # Reject literals
            s.class <= RDF::Literal
          end.select do |s|  # Select URIs and blank nodes in case of include_blank
            include_blank || s.class == RDF::URI
          end.uniq
        end

        def create_page(site, resource, mapper, global_config)
          page = RdfPageData.new(site, site.source, resource, mapper, global_config)
          if(page.complete)
            site.pages << page
            resource.add_necessities(site, page)
            resource.subResources.each {|key, value|
              value.add_necessities(site, page)
            } unless resource.subResources.nil?
          end
        end
      end

    end
  end
end
