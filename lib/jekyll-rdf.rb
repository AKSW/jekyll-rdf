##
# JekyllRdf converts RDF data into static websites
#
#
require 'jekyll'
require 'linkeddata'
require 'sparql'


require 'jekyll/drops/rdf_term'
require 'jekyll/drops/rdf_statement'
require 'jekyll/drops/rdf_literal'
require 'jekyll/drops/rdf_resource'
require 'jekyll/filters/rdf_sparql_query'
require 'jekyll/filters/rdf_property'
require 'jekyll/filters/rdf_property_list'
require 'jekyll/rdf_main_generator'
require 'jekyll/rdf_page_data'
require 'jekyll/rdf_template_mapper'
