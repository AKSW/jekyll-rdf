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
    include Jekyll::JekyllRdf::Helper::RdfGeneratorHelper

    ##
    # #generate performs the enrichment of a Jekyll::Site with rdf triples
    #
    # * +site+ - The Jekyll::Site whose #data is to be enriched
    #
    def generate(site)

      if(!load_config(site))
        return false#in case of error, exit routine
      end
      if(@config.key? "template_mapping")
        Jekyll.logger.error("Outdated format in _config.yml:\n  'template_mapping' detected but the following keys must be used now instead:\n    instance_template_mappings -> maps single resources to single layouts\n    class_template_mappings -> maps entire classes of resources to layouts\nJekyll-RDF wont render any pages for #{site.source}")
        return false
      end

      graphFile = File.join(site.config['source'], @config['path'])

      graph = RDF::Graph.load(graphFile)
      sparql = SPARQL::Client.new(graph)

      Jekyll::JekyllRdf::Helper::RdfHelper::sparql = sparql
      Jekyll::JekyllRdf::Helper::RdfHelper::site = site
      Jekyll::JekyllRdf::Helper::RdfHelper::prefixes = File.join(site.source, 'rdf-data', @config['prefixes'].strip) unless @config['prefixes'].nil?

      # restrict RDF graph with restriction
      resources = extract_resources(@config['restriction'], @config['include_blank'], sparql)
      site.data['sparql'] = sparql
      site.data['resources'] = []

      parse_resources(resources)

      mapper = Jekyll::RdfTemplateMapper.new(@config['instance_template_mappings'], @config['class_template_mappings'], @config['default_template'], sparql)

      prepare_pages(site, mapper)
      return true
    end
  end
end
