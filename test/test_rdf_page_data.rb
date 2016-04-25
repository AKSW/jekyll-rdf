require 'test_helper'

class TestRdfPageData < Test::Unit::TestCase

  context "RdfPage constructor" do

    config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
    site = Jekyll::Site.new(config)
    graph = RDF::Graph.load(config['jekyll_rdf']['path'])
    page = Jekyll::RdfPageData.new(site, site.source, RDF::URI.new("http://www.ifi.uio.no/INF3580/simpsons#Homer"), graph)

    should "have correct title" do
      assert_equal page.data['title'], "http://www.ifi.uio.no/INF3580/simpsons#Homer"
    end

    should "have 4 rdf statements" do
      assert_equal 4, page.data['rdf'].count
    end

  end

end
