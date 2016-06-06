require 'test_helper'

class TestRdfMainGenerator < Test::Unit::TestCase

  context "Resource extraction" do

    generator = Jekyll::RdfMainGenerator.new
    config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
    graph = RDF::Graph.load(config['jekyll_rdf']['path'])
    sparql = SPARQL::Client.new(graph)

    context "without blank nodes" do

      should "get 28 unique resources" do
        assert_equal 28, generator.extract_resources(nil, false, graph, sparql).count
      end

      should "get 13 subjects" do
        assert_equal 13, generator.extract_resources("subjects", false, graph, sparql).count
      end

      should "get 14 objects" do
        assert_equal 14, generator.extract_resources("objects", false, graph, sparql).count
      end

      should "get 13 predicates" do
        assert_equal 13, generator.extract_resources("predicates", false, graph, sparql).count
      end

      should "get 3 children of homer simpson" do
        assert_equal 3, generator.extract_resources("SELECT ?resourceUri WHERE { ?resourceUri <http://www.ifi.uio.no/INF3580/family#hasFather> <http://www.ifi.uio.no/INF3580/simpsons#Homer> }", false, graph, sparql).count
      end

    end

    context "with blank nodes" do

      should "get 33 unique resources" do
        assert_equal 33, generator.extract_resources(nil, true, graph, sparql).count
      end

      should "get 18 subjects" do
        assert_equal 18, generator.extract_resources("subjects", true, graph, sparql).count
      end

      should "get 19 objects" do
        assert_equal 19, generator.extract_resources("objects", true, graph, sparql).count
      end

      should "get 13 predicates" do
        assert_equal 13, generator.extract_resources("predicates", true, graph, sparql).count
      end

      should "get 3 children of homer simpson" do
        assert_equal 3, generator.extract_resources("SELECT ?resourceUri WHERE { ?resourceUri <http://www.ifi.uio.no/INF3580/family#hasFather> <http://www.ifi.uio.no/INF3580/simpsons#Homer> }", true, graph, sparql).count
      end

    end

  end

end
