module Jekyll
  module JekyllRdf
    module Helper
      module RdfGeneratorHelper
        private
        def prepare_pages (site, mapper)
          Jekyll::Page.prepend Jekyll::JekyllRdf::Helper::RdfPageHelper
          @pageResources.each{|uri, entry|
            resource = entry.delete('./')
            resource.subResources = entry
            create_page(site, resource, mapper)
          }

          @blanknodes.each{|resource|
            create_page(site, resource, mapper)
          }
        end

        def parse_resources (resources)
          @pageResources={};
          @blanknodes=[]
          resources.each do |uri|
            resource = Jekyll::JekyllRdf::Helper::RdfHelper.resources(uri)
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
            @pageResources[key]['./'] = Jekyll::JekyllRdf::Helper::RdfHelper.resources(key) if @pageResources[key]['./'].nil?
          }
        end

        def load_config (site)
          begin
            @config = site.config.fetch('jekyll_rdf')
          rescue KeyError
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

        def extract_list_resources path
          file = File.open(path, "r")
          result = []
          file.each_line {|line|
            line = line.strip
            result.push(RDF::URI(line[1..-2])) if (line[0].eql? "<" )&& (line[-1].eql? ">")
          }
          file.close
          result
        end

        def create_page(site, resource, mapper)
          Jekyll::JekyllRdf::Helper::RdfPageHelper.prepare_resource resource, mapper
          page = Jekyll::Page.new(site, site.source, resource.filedir, resource.filename)
          page.re_init_as_rdf(resource, mapper)
          if(page.complete)
            changes = false
            site.pages.map!{|old_page|
              if (old_page.url.chomp('.html') == page.url.chomp('.html'))
                changes||=true
                page.assimilate_page(old_page)
                page
              else
                old_page
              end
            }
            unless changes
              site.pages << page
            end
            page.relative_path = resource.iri
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
