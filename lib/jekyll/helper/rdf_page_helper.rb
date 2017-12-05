module Jekyll
  module JekyllRdf
    module Helper
      module RdfPageHelper
        private
        include Jekyll::JekyllRdf::Helper::RdfPrefixHelper
        ##
        # sets @template to the path of a fitting layout
        # it will set @complete to false if no fitting template is found
        # * +resource+ - the resource that will be mapped to a template
        # * +mapper+ - the mapper that provides the resource mappings
        def map_template(resource, mapper)
          @template = mapper.map(resource)
          if(@template.nil?)
            Jekyll.logger.warn("Resource #{resource} not rendered: No fitting template or default template found.")
            @complete = false
          end
        end

        ##
        # loads the data from the yaml-frontmatter and extends page.data with three key value pairs:
        # -title -> contains the resource.iri
        # -rdf -> contains the resource itself
        # -template -> contains the path to the currenly used template
        def load_data(site)
          self.read_yaml(File.join(@base, '_layouts'), @template)
          self.data['title'] = @resource.iri
          self.data['rdf'] = @resource
          self.data['template'] = @template
          if(!@resource.subResources.nil?)
            self.data['sub_rdf'] = @resource.subResources.values
            self.data['sub_rdf'].each { |res|
              res.page = self
              res.site = site
            }
          end
        end

        ##
        # loads the prefix data passed in the layout yaml-frontmatter into page.data["rdf_prefixes"] and page.data["rdf_prefix_map"]
        def load_prefixes_yaml
          if !self.data["rdf_prefix_path"].nil?
            load_prefixes(File.join(@base, 'rdf-data', self.data["rdf_prefix_path"].strip), self.data)
          end
        end
      end

    end
  end
end

