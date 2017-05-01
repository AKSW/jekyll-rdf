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
    page = Jekyll::RdfPageData.new(site, site.source, Jekyll::Drops::RdfResource.new(test_uri, graph), mapper, config)

    # for testing exceptions
    error_uri = RDF::URI.new("http://error.causing/uri#error")
    exceptionMapper = Jekyll::RdfTemplateMapper.new(config['jekyll_rdf']['instance_template_mappings'].merge({"http://error.causing/uri#error" => "testExceptions.html"}), config['jekyll_rdf']['class_template_mappings'], config['jekyll_rdf']['default_template'], graph, sparql)
    page2 = Jekyll::RdfPageData.new(site, site.source, Jekyll::Drops::RdfResource.new(error_uri, graph), exceptionMapper, config)

    special_path_uri = RDF::URI.new("http://www.ifi.uio.no/INF3580/simpsons#")
    testPathResource = Jekyll::Drops::RdfResource.new(special_path_uri, graph)

    missing_template_uri = RDF::URI.new("http://this.uri/has/no/template")
    no_template_mapper = Jekyll::RdfTemplateMapper.new(config['jekyll_rdf']['instance_template_mappings'], config['jekyll_rdf']['class_template_mappings'], nil, graph, sparql)
    missing_template_page = Jekyll::RdfPageData.new(site, site.source, Jekyll::Drops::RdfResource.new(missing_template_uri, graph), exceptionMapper, config)

    should "recognize templateless pages and resources" do
      assert(missing_template_page.complete)
    end

    should "have correct title" do
      assert_equal page.data['title'], "http://www.ifi.uio.no/INF3580/simpsons#Homer"
    end

    should "have correct job" do
      assert_equal page.data['rdf'].statements[4].object.literal, "unknown"
    end

    should "have correct translated job" do
      assert_equal page.data['rdf'].statements[5].object.literal, "unbekannt"
    end

    should "have 18 rdf statements" do
      assert_equal 18, page.data['rdf'].statements.count
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

  context "Invalid uris" do
    config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
    graph = RDF::Graph.load(config['jekyll_rdf']['path'])
    invalidResource = Jekyll::Drops::RdfResource.new("ahfkas/aljöfa,sldf/slf", graph)
    invalidResource.filename("site","base")
    should "be recognized by rdf_resource.rb" do
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /\s*Invalid resource found: .* is not a proper uri\s*/)}
    end
  end

end
