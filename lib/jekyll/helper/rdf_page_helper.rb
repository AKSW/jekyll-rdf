module Jekyll
  module JekyllRdf
    module Helper
      module RdfPageHelper
        attr_reader :complete

        def assimilate_page page
          self.data.merge!(page.data)
          setData()
          if page.data['layout'].nil?
            self.content.gsub!(/{{\s*content\s*}}/, page.content)
          else
            self.content = page.content
          end
          self
        end

        def re_init_as_rdf(resource, mapper)
          @resource = resource
          if(@base.nil?)
            Jekyll.logger.warn "Resource #{resource} not rendered: no base url found."
            @complete = false   #TODO: set a return here and adapt the test for displaying a warning for rendering a page without template
          else
            @complete = true
          end
          map_template(resource, mapper)
          return unless @complete
          load_data(@site)
          self.data['permalink'] = File.join(@dir, @name)    #overwrite permalinks to stop them from interfering with JekyllRdfs rendersystem
          return unless @complete
          load_prefixes_yaml()
          resource.page = self
          resource.site = @site
          @site.data['resources'] << resource
          @url = resource.page_url
          @url = "/" + @url unless @url[0].eql? "/"   #by default jekyll renders with a leading /
        end

        def self.prepare_resource resource, mapper
          @@template = mapper.map(resource)
          @@template.gsub!(".html", "") unless @@template.nil? #gsub only for downward compatibility // remove gsub + unless on next version update
        end

        def read_yaml(base, name, opts = {})
          @path = @site.layouts[Jekyll::JekyllRdf::Helper::RdfPageHelper.template(true)].path unless Jekyll::JekyllRdf::Helper::RdfPageHelper.template.nil?
          super(base, name, opts)
        end

        def self.template read_out = false
          template = @@template
          @@template = nil if read_out
          template
        end

        private
        include Jekyll::JekyllRdf::Helper::RdfPrefixHelper
        ##
        # sets @template to the path of a fitting layout
        # it will set @complete to false if no fitting template is found
        # * +resource+ - the resource that will be mapped to a template
        # * +mapper+ - the mapper that provides the resource mappings
        def map_template(resource, mapper)
          @template = mapper.map(resource)
          @template.gsub!(".html", "") unless @template.nil? #gsub only for downward compatibility // remove gsub + unless on next version update
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
            self.data = {}
            @complete = false
            return
          end
          setData()
          if(!@resource.subResources.nil?)
            self.data['sub_rdf'] = @resource.subResources.values
            self.data['sub_rdf'].each { |res|
              res.page = self
              res.site = site
            }
          end
        end

        def setData
          self.data['rdf'] = @resource
          self.data['template'] = @template
        end

        ##
        # loads the prefix data passed in the layout yaml-frontmatter into page.data["rdf_prefixes"] and page.data["rdf_prefix_map"]
        def load_prefixes_yaml
          unless self.data["rdf_prefix_path"].nil?
            load_prefixes(File.join(@site.layouts[@template].instance_variable_get(:@base_dir), self.data["rdf_prefix_path"].strip), self.data)
          end
        end

      end

    end
  end
end
