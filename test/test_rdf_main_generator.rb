require 'test_helper'

class TestRdfTemplateMapper < Test::Unit::TestCase
  include Jekyll::RdfGeneratorHelper
  graph = RDF::Graph.load(TestHelper::TEST_OPTIONS['jekyll_rdf']['path'])
  sparql = SPARQL::Client.new(graph)
  res_helper = ResourceHelper.new(sparql)

  context "load_config from RdfMainGenerator" do
    should "load the config correctly" do
      @test_config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
      @site = Jekyll::Site.new(@test_config)
      assert load_config(@site)
      assert_equal("http://www.ifi.uio.no", @global_config["url"])
      assert_equal("/INF3580", @global_config["baseurl"])
    end

    should "fail if jekyll-rdf is included but not configured" do
      @site = res_helper.create_bad_fetch_site()
      assert !load_config(@site), "load_config does not return false"
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /You've included Jekyll-RDF, but it is not configured. Aborting the jekyll-rdf plugin./)}, "missing error message:\nYou've included Jekyll-RDF, but it is not configured. Aborting the jekyll-rdf plugin."
    end
  end

  context "create_page from rdf_main_generator" do
    should "create a page with the right title" do
      @resources_to_templates = {
        "http://www.ifi.uio.no/INF3580/simpsons#Homer" => "homer.html",
        "http://placeholder.host.plh/placeholder#Placeholder" => "Placeholder"
        }
      @classes_to_templates = {
        "http://xmlns.com/foaf/0.1/Person" => "person.html",
        "http://pcai042.informatik.uni-leipzig.de/~dtp16/#SpecialPerson" => "SpecialPerson",
        "http://pcai042.informatik.uni-leipzig.de/~dtp16/#AnotherSpecialPerson" => "AnotherSpecialPerson"
      }
      @default_template = "default.html"
      res_helper.global_site = true
      @resource1 = res_helper.basic_resource("http://www.ifi.uio.no/INF3580/simpsons#Homer")
      @resource2 = res_helper.basic_resource("http://www.ifi.uio.no/INF3580/simpsons#Maggie")
      @resource3 = res_helper.basic_resource("http://resource3")
      res_helper.global_site = false
      @mapper = Jekyll::RdfTemplateMapper.new(@resources_to_templates, @classes_to_templates, @default_template, sparql)
      config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
      site = Jekyll::Site.new(config)
      site.data['resources'] = []
      create_page(site, @resource1, @mapper, config)
      create_page(site, @resource2, @mapper, config)
      create_page(site, @resource3, @mapper, config)
      assert_equal "http://www.ifi.uio.no/INF3580/simpsons#Homer", site.pages[0].data['title']
      assert_equal "http://www.ifi.uio.no/INF3580/simpsons#Maggie", site.pages[1].data['title']
      assert_equal "http://resource3", site.pages[2].data['title']
    end
  end

  context "parse_resources from rdf_main_generator" do
    should "create multiple 2 nodes deep hierarchy" do
      resources = []
      resources << RDF::URI.new("http://www.ifi.uio.no/INF3580/simpsons#Homer")
      resources << RDF::URI.new("http://www.ifi.uio.no/INF3580/simpsons#Marge")
      resources << RDF::URI.new("http://www.ifi.uio.no/INF3580/simpsons#Bart")
      resources << RDF::URI.new("http://www.ifi.uio.no/INF3580/simpsons#Lisa")
      resources << RDF::URI.new("http://www.ifi.uio.no/INF3580/simpsons#Maggie")
      resources << RDF::URI.new("http://www.ifi.uio.no/INF3580/simpsons")
      resources << RDF::URI.new("http://www.ifi.uio.no/INF3580/family#Max")
      resources << RDF::URI.new("http://www.ifi.uio.no/INF3580/family#Jeanne")
      resources << RDF::Node.new
      resources << RDF::Node.new
      parse_resources(resources, sparql)
      assert_equal "http://www.ifi.uio.no/INF3580/simpsons", @pageResources["http://www.ifi.uio.no/INF3580/simpsons"]["./"].to_s
      assert_equal "http://www.ifi.uio.no/INF3580/simpsons#Homer", @pageResources["http://www.ifi.uio.no/INF3580/simpsons"]["Homer"].to_s
      assert_equal "http://www.ifi.uio.no/INF3580/simpsons#Marge", @pageResources["http://www.ifi.uio.no/INF3580/simpsons"]["Marge"].to_s
      assert_equal "http://www.ifi.uio.no/INF3580/simpsons#Bart", @pageResources["http://www.ifi.uio.no/INF3580/simpsons"]["Bart"].to_s
      assert_equal "http://www.ifi.uio.no/INF3580/simpsons#Lisa", @pageResources["http://www.ifi.uio.no/INF3580/simpsons"]["Lisa"].to_s
      assert_equal "http://www.ifi.uio.no/INF3580/simpsons#Maggie", @pageResources["http://www.ifi.uio.no/INF3580/simpsons"]["Maggie"].to_s
      assert_equal "http://www.ifi.uio.no/INF3580/family#Max", @pageResources["http://www.ifi.uio.no/INF3580/family"]["Max"].to_s
      assert_equal "http://www.ifi.uio.no/INF3580/family#Jeanne", @pageResources["http://www.ifi.uio.no/INF3580/family"]["Jeanne"].to_s
      assert_equal nil, @pageResources["http://www.ifi.uio.no/INF3580/family"]["./"]
      assert_equal 2, @blanknodes.size
    end
  end

  context "prepare_pages from rdf_main_generator" do
    setup do
      @pageResources = {
        "http://www.ifi.uio.no/INF3580/simpsons" => {
          "./" => Jekyll::Drops::RdfResource.new("http://www.ifi.uio.no/INF3580/simpsons", sparql),
          "Homer" => Jekyll::Drops::RdfResource.new("http://www.ifi.uio.no/INF3580/simpsons/Homer", sparql),
          "Marge" => Jekyll::Drops::RdfResource.new("http://www.ifi.uio.no/INF3580/simpsons/Marge", sparql)
        },
        "http://www.ifi.uio.no/INF3580/family" => {
          "Max" => Jekyll::Drops::RdfResource.new("http://www.ifi.uio.no/INF3580/family/Max", sparql),
          "Jeanne" => Jekyll::Drops::RdfResource.new("http://www.ifi.uio.no/INF3580/family/Jeanne", sparql),
        }
      }
      @blanknodes = []
      @blanknodes << Jekyll::Drops::RdfResource.new(RDF::Node.new, sparql)
      @blanknodes << Jekyll::Drops::RdfResource.new(RDF::Node.new, sparql)
      @resources_to_templates = {
        "http://www.ifi.uio.no/INF3580/simpsons#Homer" => "homer.html",
        "http://placeholder.host.plh/placeholder#Placeholder" => "Placeholder",
        "http://www.ifi.uio.no/INF3580/simpsons" => "page.html"
      }
      @classes_to_templates = {
        "http://xmlns.com/foaf/0.1/Person" => "person.html"
      }
      @default_template = "default.html"
    end

    should "prepare pages for each resource given" do
      @global_config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
      @config = Jekyll.configuration({'render_orphaned_uris' => true})
      site = Jekyll::Site.new(@global_config)
      site.data['resources'] = []
      @mapper = Jekyll::RdfTemplateMapper.new(@resources_to_templates, @classes_to_templates, @default_template, sparql)
      prepare_pages(site, @mapper)
      index = site.pages.find_index {|page| page.data['title'] == "http://www.ifi.uio.no/INF3580/simpsons"}
      assert !index.nil?, "page http://www.ifi.uio.no/INF3580/simpsons not found"
      assert_equal "page.html", site.pages[index].data['template']
      index = site.pages.find_index {|page| page.data['title'] == "http://www.ifi.uio.no/INF3580/family/Max"}
      assert !index.nil?, "page http://www.ifi.uio.no/INF3580/family/Max not found"
      assert_equal "default.html", site.pages[index].data['template']
      index = site.pages.find_index {|page| page.data['title'] == "http://www.ifi.uio.no/INF3580/family/Jeanne"}
      assert !index.nil?, "page http://www.ifi.uio.no/INF3580/family/Jeanne not found"
      assert_equal "default.html", site.pages[index].data['template']
      assert_equal 5, site.pages.size
    end
  end

  context "extract_resources from rdf_main_generator" do
    should "extract all subjects from the given source" do
      selection = "subjects"
      resources = extract_resources(selection, false, sparql)
      assert resources.size > 30, "number of subjects should be higher then 30"
      assert resources.any? {|res| res.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"}, "subjects should contain http://www.ifi.uio.no/INF3580/simpsons#Homer"
      assert !resources.any? {|res| res.to_s.eql? "http://www.ifi.uio.no/INF3580/family#Family"}, "subjects should not contain http://www.ifi.uio.no/INF3580/family#Family"
      assert !resources.any? {|res| res.to_s.eql? "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"}, "subjects should not contain http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
      assert !resources.any? {|res| res.class.eql? RDF::Node}, "subjects should not contain any blanknodes"
    end

    should "extract all objects from the given source" do
      selection = "objects"
      resources = extract_resources(selection, false, sparql)
      assert resources.size > 27, "number of objects should be higher then 27"
      assert resources.any? {|res| res.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"}, "objects should contain http://www.ifi.uio.no/INF3580/simpsons#Homer"
      assert resources.any? {|res| res.to_s.eql? "http://www.ifi.uio.no/INF3580/family#Family"}, "objects should contain http://www.ifi.uio.no/INF3580/family#Family"
      assert !resources.any? {|res| res.to_s.eql? "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"}, "objects should not contain http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
      assert !resources.any? {|res| res.class.eql? RDF::Node}, "objects should not contain any blanknodes"
    end

    should "extract all predicates from the given source" do
      selection = "predicates"
      resources = extract_resources(selection, false, sparql)
      assert resources.size > 22, "number of predicates should be higher then 22"
      assert !resources.any? {|res| res.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons/Homer"}, "predicates should not contain http://www.ifi.uio.no/INF3580/simpsons/Homer"
      assert !resources.any? {|res| res.to_s.eql? "http://www.ifi.uio.no/INF3580/family#Family"}, "predicates should not contain http://www.ifi.uio.no/INF3580/family#Family"
      assert resources.any? {|res| res.to_s.eql? "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"}, "predicates should contain http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
      assert !resources.any? {|res| res.class.eql? RDF::Node}, "predicates should not contain any blanknodes"
    end

    should "extract all anwers of a query from the given source" do
      selection = "SELECT ?resourceUri WHERE{ ?resourceUri ?p ?o}"
      resources = extract_resources(selection, false, sparql)
      assert resources.size > 30, "number of solutions without blanknodes should be higher then 30"
      assert resources.any? {|res| res.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"}, "subjects should contain http://www.ifi.uio.no/INF3580/simpsons#Homer"
      assert !resources.any? {|res| res.to_s.eql? "http://www.ifi.uio.no/INF3580/family#Family"}, "subjects should not contain http://www.ifi.uio.no/INF3580/family#Family"
      assert !resources.any? {|res| res.to_s.eql? "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"}, "subjects should not contain http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
      assert !resources.any? {|res| res.class.eql? RDF::Node}, "the query solutions should not contain any blanknodes"
    end

    should "extract all anwers of a query including blanknodes from the given source" do
      selection = "SELECT ?resourceUri WHERE{ ?resourceUri ?p ?o}"
      resources = extract_resources(selection, true, sparql)
      assert resources.size > 35, "number of solutions without blanknodes should be higher then 35"
      assert resources.any? {|res| res.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"}, "subjects should contain http://www.ifi.uio.no/INF3580/simpsons#Homer"
      assert !resources.any? {|res| res.to_s.eql? "http://www.ifi.uio.no/INF3580/family#Family"}, "subjects should not contain http://www.ifi.uio.no/INF3580/family#Family"
      assert !resources.any? {|res| res.to_s.eql? "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"}, "subjects should not contain http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
      assert resources.any? {|res| res.class.eql? RDF::Node}, "the query solutions should contain blanknodes"
    end
  end

  context "generate from rdf_main_generator" do
    setup do
      @site = Jekyll::Site.new Jekyll.configuration(TestHelper::TEST_OPTIONS)
      @fail_fetch_site = res_helper.create_bad_fetch_site()
      @old_config_site = Jekyll::Site.new Jekyll.configuration({"jekyll_rdf" => {"template_mapping" => ""}})
      @generator = Jekyll::RdfMainGenerator.new
    end

    should "work without any interupts" do
      exit = true
      assert_nothing_raised do
         exit = @generator.generate(@site)
      end
      assert exit, "generator exited early"
    end

    should "fail if it can't load _config.yml" do
      assert !@generator.generate(@fail_fetch_site), "the gerate process should not have been cleanly exited"
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /You've included Jekyll-RDF, but it is not configured. Aborting the jekyll-rdf plugin./)}, "The should exit with the error message: ''You've included Jekyll-RDF, but it is not configured. Aborting the jekyll-rdf plugin.''"
    end

    should "fail if template_mapping is defined in _config.yml" do
      assert !@generator.generate(@old_config_site), "the gerate process should not have been cleanly exited"
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /Outdated format in _config\.yml:\n  'template_mapping' detected but the following keys must be used now instead:\n    instance_template_mappings -> maps single resources to single layouts\n    class_template_mappings -> maps entire classes of resources to layouts\nJekyll-RDF wont render any pages for .*/)}, "The generate process should exit with the error message: \nOutdated format in _config.yml:\n  'template_mapping' detected but the following keys must be used now instead:\n    instance_template_mappings -> maps single resources to single layouts\n    class_template_mappings -> maps entire classes of resources to layouts\nJekyll-RDF wont render any pages for \*\*\*\*"
    end
  end
end