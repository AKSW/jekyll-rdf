require 'test_helper'

class TestRdfTemplateMapper < Test::Unit::TestCase
  include RdfTestUtility
  context "load_config from RdfMainGenerator" do
    setup do
      setup_site_jekyll "cases/mainGenerator"
    end

    should "load baseiri if available" do
      assert_equal "http://example.org/", Jekyll::JekyllRdf::Helper::RdfHelper::domainiri
      assert_equal "/instance", Jekyll::JekyllRdf::Helper::RdfHelper::pathiri
    end

    should "fail if jekyll-rdf is included but not configured" do
      TestHelper::setErrOutput
      @source = File.join(File.dirname(__FILE__), "cases/missingConfig")
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
      site = Jekyll::Site.new(config)
      site.process
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /You've included Jekyll-RDF, but it is not configured. Aborting the jekyll-rdf plugin./)}, "The should exit with the error message: ''You've included Jekyll-RDF, but it is not configured. Aborting the jekyll-rdf plugin.''"
      TestHelper::resetErrOutput
    end
  end

  context "rdf_main_generator resource extraction" do
    should "extract all subjects from the given source" do
      @source = File.join(File.dirname(__FILE__), "cases/extraction")
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
      config['jekyll_rdf']['restriction'] = "subjects"
      site = Jekyll::Site.new(config)
      site.process
      resources = site.pages.collect {|page| page.data['rdf'] unless page.data['rdf'].nil?}
      assert resources.any? {|res| res.to_s.eql? "http://example.org/instance/resource1"}, "subjects should contain http://example.org/instance/resource1"
      assert !resources.any? {|res| res.to_s.eql? "http://example.org/instance/predicate1"}, "subjects should not contain http://example.org/instance/predicate1"
      assert !resources.any? {|res| res.to_s.eql? "http://example.org/instance/object1"}, "subjects should not contain http://example.org/instance/object1"
      assert !resources.any? {|res| res.class.eql? RDF::Node}, "subjects should not contain any blanknodes"
    end

    should "extract all objects from the given source" do
      @source = File.join(File.dirname(__FILE__), "cases/extraction")
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
      config['jekyll_rdf']['restriction'] = "objects"
      site = Jekyll::Site.new(config)
      site.process
      resources = site.pages.collect {|page| page.data['rdf'] unless page.data['rdf'].nil?}
      assert !resources.any? {|res| res.to_s.eql? "http://example.org/instance/resource1"}, "objects should contain http://example.org/instance/resource1"
      assert !resources.any? {|res| res.to_s.eql? "http://example.org/instance/predicate1"}, "objects should contain http://example.org/instance/predicate1"
      assert resources.any? {|res| res.to_s.eql? "http://example.org/instance/object1"}, "objects should not contain http://example.org/instance/object1"
      assert !resources.any? {|res| res.class.eql? RDF::Node}, "objects should not contain any blanknodes"
    end

    should "extract all predicates from the given source" do
      @source = File.join(File.dirname(__FILE__), "cases/extraction")
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
      config['jekyll_rdf']['restriction'] = "predicates"
      site = Jekyll::Site.new(config)
      site.process
      resources = site.pages.collect {|page| page.data['rdf'] unless page.data['rdf'].nil?}
      assert !resources.any? {|res| res.to_s.eql? "http://example.org/instance/resource1"}, "predicates should not contain http://example.org/instance/resource1"
      assert resources.any? {|res| res.to_s.eql? "http://example.org/instance/predicate1"}, "predicates should not contain http://example.org/instance/predicate1"
      assert !resources.any? {|res| res.to_s.eql? "http://example.org/instance/object1"}, "predicates should contain http://example.org/instance/object1"
      assert !resources.any? {|res| res.class.eql? RDF::Node}, "predicates should not contain any blanknodes"
    end

    should "extract all anwers of a query from the given source" do
      @source = File.join(File.dirname(__FILE__), "cases/extraction")
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
      config['jekyll_rdf']['restriction'] = "SELECT ?resourceUri WHERE{ ?resourceUri ?p ?o}"
      site = Jekyll::Site.new(config)
      site.process
      resources = site.pages.collect {|page| page.data['rdf'] unless page.data['rdf'].nil?}
      assert resources.any? {|res| res.to_s.eql? "http://example.org/instance/resource1"}, "subjects should contain http://example.org/instance/resource1"
      assert !resources.any? {|res| res.to_s.eql? "http://example.org/instance/predicate1"}, "subjects should not contain http://example.org/instance/predicate1"
      assert !resources.any? {|res| res.to_s.eql? "http://example.org/instance/object1"}, "subjects should not contain http://example.org/instance/object1"
      assert !resources.any? {|res| res.class.eql? RDF::Node}, "the query solutions should not contain any blanknodes"
    end
  end

  context "generate from rdf_main_generator" do
    should "work without any interupts" do
      assert_nothing_raised do
        setup_jekyll "cases/mainGenerator"
      end
    end

    should "fail if template_mapping is defined in _config.yml" do
      TestHelper::setErrOutput
      @source = File.join(File.dirname(__FILE__), "cases/mainGenerator")
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site"), 'jekyll_rdf' => {'template_mapping' => ''}}))
      site = Jekyll::Site.new(config)
      site.process
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /Outdated format in _config\.yml:\n  'template_mapping' detected but the following keys must be used now instead:\n    instance_template_mappings -> maps single resources to single layouts\n    class_template_mappings -> maps entire classes of resources to layouts\nJekyll-RDF wont render any pages for .*/)}, "The generate process should exit with the error message: \nOutdated format in _config.yml:\n  'template_mapping' detected but the following keys must be used now instead:\n    instance_template_mappings -> maps single resources to single layouts\n    class_template_mappings -> maps entire classes of resources to layouts\nJekyll-RDF wont render any pages for \*\*\*\*"
      TestHelper::resetErrOutput
    end
  end
end
