require 'test_helper'

class TestRdfPageData < Test::Unit::TestCase

  context "RdfPage" do

    config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
    site = Jekyll::Site.new(config)
    site.data['resources'] = []
    graph = RDF::Graph.load(config['jekyll_rdf']['path'])
	sparql = SPARQL::Client.new(graph)
    mapper = Jekyll::RdfTemplateMapper.new(config['jekyll_rdf']['instance_template_mappings'], config['jekyll_rdf']['class_template_mappings'], config['jekyll_rdf']['default_template'], graph, sparql)
    test_uri = RDF::URI.new("http://www.ifi.uio.no/INF3580/simpsons#Homer")
    page = Jekyll::RdfPageData.new(site, site.source, Jekyll::Drops::RdfResource.new(test_uri, graph), mapper)

    should "have correct title" do
      assert_equal page.data['title'], "http://www.ifi.uio.no/INF3580/simpsons#Homer"
    end

    should "have correct job" do
      assert_equal page.data['rdf'].statements[4].object.name, "unknown"
    end

    should "have correct translated job" do
      assert_equal page.data['rdf'].statements[5].object.name, "unbekannt"
    end

    should "have 14 rdf statements" do
      assert_equal 14, page.data['rdf'].statements.count
    end

  end

end
