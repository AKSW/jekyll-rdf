require 'test_helper'

class TestRdfPageData < Test::Unit::TestCase

  context "RdfPage" do

    config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
    site = Jekyll::Site.new(config)
    site.data['resources'] = []
    graph = RDF::Graph.load(config['jekyll_rdf']['path'])
    test_uri = RDF::URI.new("http://www.ifi.uio.no/INF3580/simpsons#Homer")
    page = Jekyll::RdfPageData.new(site, site.source, Jekyll::Drops::RdfResource.new(test_uri, graph))

    should "have correct title" do
      assert_equal page.data['title'], "Homer Simpson"
    end

    should "have 9 rdf statements" do
      assert_equal 9, page.data['rdf'].statements.count
    end

  end

end
