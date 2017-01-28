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

    ##
    # initialize initializes the page
    # * +site+ - The Jekyll site we want to enrich with RDF data
    # * +base+ - The base of the site
    # * +resource+ - The RDF resource for which the page is rendered
    # * +mapper+ - The layout-mapping
    #
    def initialize(site, base, resource, mapper)
      @site = site
      @base = base
      @dir = ""
      @name = resource.filename(URI::split(site.config['url'])[2], site.config['baseurl'])
      self.process(@name)

      template = mapper.map(resource)
      self.read_yaml(File.join(base, '_layouts'), template)
      self.data['title'] = resource.name
      self.data['rdf'] = resource
      if(!resource.subResources.nil?)
        self.data['sub_rdf'] = resource.subResources.values
        self.data['sub_rdf'].each { |res|
          res.page = self
          res.site = site
        }
      end
      if !self.data["rdf_prefix_path"].nil?
        begin
          prefixFile=File.new(File.join(base, 'rdf-data', self.data["rdf_prefix_path"].strip)).readlines
          self.data["rdf_prefixes"] = prefixFile.join(" ")
          self.data["rdf_prefix_map"] = Hash[ *(prefixFile.collect { |v|
            arr = v.split(":",2)
            [arr[0][7..-1].strip, arr[1].strip[1..-2]]
          }.flatten)]
        rescue Errno::ENOENT => ex
          Jekyll.logger.error("context: #{resource.name}  template: #{template}  file not found: #{File.join(base, 'rdf-data', self.data["rdf_prefix_path"])}")
        end
      end
      resource.page = self
      resource.site = site
      site.data['resources'] << resource
    end

  end

end
