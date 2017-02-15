require 'test_helper'
require 'pp'

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

    # for testing exceptions
    error_uri = RDF::URI.new("http://error.causing/uri#error")
    exceptionMapper = Jekyll::RdfTemplateMapper.new(config['jekyll_rdf']['instance_template_mappings'].merge({"http://error.causing/uri#error" => "testExceptions.html"}), config['jekyll_rdf']['class_template_mappings'], config['jekyll_rdf']['default_template'], graph, sparql)
    page2 = Jekyll::RdfPageData.new(site, site.source, Jekyll::Drops::RdfResource.new(error_uri, graph), exceptionMapper)

    special_path_uri = RDF::URI.new("http://www.ifi.uio.no/INF3580/simpsons#")
    testPathResource = Jekyll::Drops::RdfResource.new(special_path_uri, graph)


    should "have correct title" do
      assert_equal page.data['title'], "http://www.ifi.uio.no/INF3580/simpsons#Homer"
    end

    should "have correct job" do
      assert_equal page.data['rdf'].statements[4].object.literal, "unknown"
    end

    should "have correct translated job" do
      assert_equal page.data['rdf'].statements[5].object.literal, "unbekannt"
    end

    should "have 16 rdf statements" do
      assert_equal 16, page.data['rdf'].statements.count
    end

    should "have ambigious ambigious template mapping for PersonClass" do  #PersonClass originates from simpsons.ttl
      assert mapper.classResources["http://pcai042.informatik.uni-leipzig.de/~dtp16/#PersonClass"].multipleTemplates?
    end

    should "identify to each resource the place the resource should be rendered to" do
      path = testPathResource.filename( TestHelper::DOMAIN_NAME, TestHelper::BASE_URL)
      assert path.eql? "rdfsites/http/www.ifi.uio.no/INF3580/simpsons/index.html"
    end

  end

  context "Jekyll.logger " do

    should "contain a prefix-file not found message" do
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /context: .*  template: .*  file not found: (\/|.)*\.pref/)}
    end

  end

end
