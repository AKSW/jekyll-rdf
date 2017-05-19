require 'test_helper'

class TestRdfMainGenerator < Test::Unit::TestCase

  context "Resource extraction" do

    generator = Jekyll::RdfMainGenerator.new
    config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
    graph = RDF::Graph.load(config['jekyll_rdf']['path'])
    sparql = SPARQL::Client.new(graph)

    config["jekyll_rdf"] = config["jekyll_rdf"].merge({"template_mapping" => {}})
    errorConfig = config
    fakeSite = Object.new
    def fakeSite.config= c
      @config=c
    end
    def fakeSite.config
      @config
    end
    def fakeSite.source
      "error test source"
    end
    fakeSite.config = errorConfig
    generator.generate(fakeSite)

    badSite = Object.new
    emptyConfig = Object.new
    def emptyConfig.fetch x
      throw Exception
    end
    def badSite.config= c
      @config = c
    end
    def badSite.config
      @config
    end

    badSite.config = emptyConfig #causes site.config.fetch to fail
    generator.generate(badSite)

    context "without blank nodes" do

      should "get 58 unique resources" do
        assert_equal 58, generator.extract_resources(nil, false, graph, sparql).count
      end

      should "get 30 subjects" do
        assert_equal 30, generator.extract_resources("subjects", false, graph, sparql).count
      end

      should "get 27 objects" do
        assert_equal 27, generator.extract_resources("objects", false, graph, sparql).count
      end

      should "get 21 predicates" do
        assert_equal 21, generator.extract_resources("predicates", false, graph, sparql).count
      end

      should "get 3 children of homer simpson" do
        assert_equal 3, generator.extract_resources("SELECT ?resourceUri WHERE { ?resourceUri <http://www.ifi.uio.no/INF3580/family#hasFather> <http://www.ifi.uio.no/INF3580/simpsons#Homer> }", false, graph, sparql).count
      end

    end

    context "with blank nodes" do

      should "get 64 unique resources" do
        assert_equal 64, generator.extract_resources(nil, true, graph, sparql).count
      end

      should "get 35 subjects" do
        assert_equal 35, generator.extract_resources("subjects", true, graph, sparql).count
      end

      should "get 32 objects" do
        assert_equal 32, generator.extract_resources("objects", true, graph, sparql).count
      end

      should "get 22 predicates" do
        assert_equal 22, generator.extract_resources("predicates", true, graph, sparql).count
      end

      should "get 3 children of homer simpson" do
        assert_equal 3, generator.extract_resources("SELECT ?resourceUri WHERE { ?resourceUri <http://www.ifi.uio.no/INF3580/family#hasFather> <http://www.ifi.uio.no/INF3580/simpsons#Homer> }", true, graph, sparql).count
      end

    end

  end

  context "an old config format" do
    should "throw an error message" do
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /Outdated format in _config\.yml:\n  'template_mapping' detected but the following keys must be used now instead:\n    instance_template_mappings -> maps single resources to single layouts\n    class_template_mappings -> maps entire classes of resources to layouts\nJekyll-RDF wont render any pages for .*/)}
    end

  end
  context "using jekyll-rdf without configuration" do
    should "throw an error message" do
      assert Jekyll.logger.messages.any? {|message| !!(message=~ /\s*You've included Jekyll-RDF, but it is not configured. Aborting the jekyll-rdf plugin.\s*/)}
    end
  end

  context "rendering a page without a template" do
    generator = Jekyll::RdfMainGenerator.new
    emptyMapper = Object.new
    def emptyMapper.map x
      nil
    end
    fakeConfig = {'url' => "test", 'baseurl' => "baseurl"}
    fakeResource = Object.new
    def fakeResource.filename a, b
      "test/URI"
    end
    def fakeResource.to_s
      "fakeResource"
    end
    fakeSite = Object.new
    def fakeSite.source
      nil
    end
    generator.createPage(fakeSite, fakeResource, emptyMapper, fakeConfig)
    should "display a warning" do
      assert Jekyll.logger.messages.any? {|message| !!(message=~ /\s*Resource .* not rendered: No fitting template or default template found\.\s*/)}
    end
  end

end
