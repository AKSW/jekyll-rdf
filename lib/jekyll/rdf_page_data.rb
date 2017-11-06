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
    include Jekyll::RdfPageHelper
    attr_reader :complete

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
        Jekyll::RdfHelper::warn_log "Resource #{resource} not rendered: no base url found."
        @complete = false   #TODO: set a return here and adapt the test for displaying a warning for rendering a page without template
      else
        @complete = true
      end
      self.process(@name)
      map_template(resource, mapper)

      if(!@complete)
        return        #return if something went wrong
      end
      load_data(site)
      load_prefixes()
      resource.page = self
      resource.site = site
      site.data['resources'] << resource
    end
  end
end