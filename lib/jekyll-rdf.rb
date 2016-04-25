require 'linkeddata'
require 'sparql'

##
# JekyllRdf converts RDF data into static websites
#
# 
module JekyllRdf
  ##
  #
  # JekyllRdf::Generator enriches site.data with rdf triples
  #
  class RdfPageData < Jekyll::Page
    def initialize(site, base, subject, graph)
      @site = site
      @base = base
      @dir = "rdfsites" #todo
      @name = subject.to_s + ".html"
      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), 'rdf_index.html')
      self.data['title'] = subject.to_s
      graphedit = graph.query(:subject => subject)
      self.data['rdf'] = graphedit.statements.map do |statement|
      [
        statement.subject.to_s,
        statement.predicate.to_s,
        statement.object.to_s
      ]
      end
    end
  end
  
  class MainGenerator < Jekyll::Generator
    safe true
    priority :highest

    ##
    # #generate performs the enrichment of site.data with rdf triples
    #
    # * +site+ - The site whose data is to be enriched
    #
    def generate(site)
      config = site.config.fetch('jekyll_rdf')

      graph = RDF::Graph.load(config['path'])
      
      graph.subjects.each do |subject|
        site.pages << RdfPageData.new(site, site.source, subject, graph)
      end
    end
  end
end
