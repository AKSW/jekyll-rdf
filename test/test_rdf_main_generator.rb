require 'test_helper'

class TestRdfMainGenerator < Test::Unit::TestCase

  context "Resource extraction" do

    generator = Jekyll::RdfMainGenerator.new
    config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
    graph = RDF::Graph.load(config['jekyll_rdf']['path'])
    sparql = SPARQL::Client.new(graph)

    should "get 23 unique resources" do
      assert_equal 23, generator.extract_resources(nil, graph, sparql).count
    end

    should "get 11 subjects" do
      assert_equal 11, generator.extract_resources("subjects", graph, sparql).count
    end

    should "get 12 objects" do
      assert_equal 12, generator.extract_resources("objects", graph, sparql).count
    end

    should "get 10 predicates" do
      assert_equal 10, generator.extract_resources("predicates", graph, sparql).count
    end

    should "get 3 children of homer simpson" do
      assert_equal 3, generator.extract_resources("SELECT ?s WHERE { ?s <http://www.ifi.uio.no/INF3580/family#hasFather> <http://www.ifi.uio.no/INF3580/simpsons#Homer> }", graph, sparql).count
    end

  end

end
