require 'test_helper'

class TestRdfMainGenerator < Test::Unit::TestCase

  context "Resource extraction" do

    generator = Jekyll::RdfMainGenerator.new
    config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
    graph = RDF::Graph.load(config['jekyll_rdf']['path'])
    sparql = SPARQL::Client.new(graph)

    context "without blank nodes" do

      should "get 25 unique resources" do
        assert_equal 25, generator.extract_resources(nil, false, graph, sparql).count
      end

      should "get 12 subjects" do
        assert_equal 12, generator.extract_resources("subjects", false, graph, sparql).count
      end

      should "get 13 objects" do
        assert_equal 13, generator.extract_resources("objects", false, graph, sparql).count
      end

      should "get 11 predicates" do
        assert_equal 11, generator.extract_resources("predicates", false, graph, sparql).count
      end

      should "get 3 children of homer simpson" do
        assert_equal 3, generator.extract_resources("SELECT ?resourceUri WHERE { ?resourceUri <http://www.ifi.uio.no/INF3580/family#hasFather> <http://www.ifi.uio.no/INF3580/simpsons#Homer> }", false, graph, sparql).count
      end

    end

    context "with blank nodes" do

      should "get 30 unique resources" do
        assert_equal 30, generator.extract_resources(nil, true, graph, sparql).count
      end

      should "get 17 subjects" do
        assert_equal 17, generator.extract_resources("subjects", true, graph, sparql).count
      end

      should "get 18 objects" do
        assert_equal 18, generator.extract_resources("objects", true, graph, sparql).count
      end

      should "get 11 predicates" do
        assert_equal 11, generator.extract_resources("predicates", true, graph, sparql).count
      end

      should "get 3 children of homer simpson" do
        assert_equal 3, generator.extract_resources("SELECT ?resourceUri WHERE { ?resourceUri <http://www.ifi.uio.no/INF3580/family#hasFather> <http://www.ifi.uio.no/INF3580/simpsons#Homer> }", true, graph, sparql).count
      end

    end

  end

end
