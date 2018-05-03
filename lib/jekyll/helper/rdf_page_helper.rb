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
          @template = mapper.map(resource).gsub(".html", "") unless mapper.map(resource).nil? #gsub only for downward compatibility // remove gsub + unless on next version update
          if(@template.nil?)
            Jekyll.logger.warn("Resource #{resource} not rendered: No fitting template or default template found.")
            @complete = false
            return
          end
        end

        ##
        # loads the data from the yaml-frontmatter and extends page.data with three key value pairs:
        # -title -> contains the resource.iri
        # -rdf -> contains the resource itself
        # -template -> contains the path to the currently used template
        def load_data(site)
          if(@site.layouts[@template].nil?)
            Jekyll.logger.error "Template #{@template} was not loaded by Jekyll for #{self.name}.\n Skipping Page."
            @complete = false
            return
          end
          @path = @site.layouts[@template].path
          self.read_yaml(@site.layouts[@template].instance_variable_get(:@base_dir), @site.layouts[@template].name)
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
            load_prefixes(File.join(@site.layouts[@template].instance_variable_get(:@base_dir), self.data["rdf_prefix_path"].strip), self.data)
          end
        end
      end

    end
  end
end

