require 'test_helper'

class TestRdfTemplateMapper < Test::Unit::TestCase
  graph = RDF::Graph.load(TestHelper::TEST_OPTIONS['jekyll_rdf']['path'])
  sparql = SPARQL::Client.new(graph)
  res_helper = ResourceHelper.new(sparql)

  
end
