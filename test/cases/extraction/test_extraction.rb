require 'test_helper'

class TestExtraction < Test::Unit::TestCase
  include RdfTestUtility
  context "rdf_main_generator resource extraction" do
    should "extract all subjects from the given source" do
      @source = File.dirname(__FILE__)
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
      @source = File.dirname(__FILE__)
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
      @source = File.dirname(__FILE__)
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
      @source = File.dirname(__FILE__)
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
end
