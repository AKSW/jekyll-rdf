require 'test_helper'

class TestRdfPageData < Test::Unit::TestCase

  context "RdfPage" do

    config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
    site = Jekyll::Site.new(config)
    site.data['resources'] = []
    graph = RDF::Graph.load(config['jekyll_rdf']['path'])
    mapper = Jekyll::RdfTemplateMapper.new(config['jekyll_rdf']['template_mappings'], config['jekyll_rdf']['default_template'])
    test_uri = RDF::URI.new("http://www.ifi.uio.no/INF3580/simpsons#Homer")
    page = Jekyll::RdfPageData.new(site, site.source, Jekyll::Drops::RdfResource.new(test_uri, graph), mapper)

    should "have correct title" do
      assert_equal page.data['title'], "Homer Simpson"
    end

    should "have correct job" do
      assert_equal page.data['rdf'].statements[3].object.name, "unknown"
    end

    should "have correct translated job" do
      assert_equal page.data['rdf'].statements[4].object.name, "unbekannt"
    end

    should "have 13 rdf statements" do
      assert_equal 13, page.data['rdf'].statements.count
    end

  end

end
