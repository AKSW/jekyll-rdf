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
  # JekyllRdf::RdfPageData creates pages for each RDF resource using a given template
  #
  class RdfPageData < Jekyll::Page
    attr_accessor :complete

    ##
    # initialize initializes the page
    # * +site+ - The Jekyll site we want to enrich with RDF data
    # * +base+ - The base of the site
    # * +resource+ - The RDF resource for which the page is rendered
    # * +mapper+ - The layout-mapping
    #
    def initialize(site, base, resource, mapper, config)
      @site = site
      @base = base
      @dir = ""
      @name = resource.filename(URI::split(config['url'])[2], config['baseurl'])
      @resource = resource
      if(base.nil?)
        Jekyll.logger.warn "Resource #{resource} not rendered: no base url found."
        @complete = false   #TODO: set a return here and adapt the test for displaying a warning for rendering a page without template
      else
        @complete = true
      end
      self.process(@name)
      map_template(resource, mapper)

      if(!@complete)
        return        #return if something went wrong
      end
      load_data
      load_prefixes()
      resource.page = self
      resource.site = site
      site.data['resources'] << resource
    end

    ##
    # sets @template to the path of a fitting layout
    # it will set @complete to false if no fitting template is found
    # * +resource+ - the resource that will be mapped to a template
    # * +mapper+ - the mapper that provides the resource mappings
    def map_template(resource, mapper)
      @template = mapper.map(@resource)
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
    def load_data
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
    def load_prefixes
      if !self.data["rdf_prefix_path"].nil?
        begin
          prefixFile=File.new(File.join(@base, 'rdf-data', self.data["rdf_prefix_path"].strip)).readlines
          self.data["rdf_prefixes"] = prefixFile.join(" ")
          self.data["rdf_prefix_map"] = Hash[ *(prefixFile.collect { |v|
            arr = v.split(":",2)
            [arr[0][7..-1].strip, arr[1].strip[1..-2]]
          }.flatten)]
        rescue Errno::ENOENT => ex
          Jekyll.logger.error("context: #{@resource}  template: #{@template}  file not found: #{File.join(@base, 'rdf-data', self.data["rdf_prefix_path"])}")
        end
      end
    end

  end

end
