require 'test_helper'

class TestRdfTemplateMapper < Test::Unit::TestCase
  include Jekyll::RdfPageHelper
  graph = RDF::Graph.load(TestHelper::TEST_OPTIONS['jekyll_rdf']['path'])
  sparql = SPARQL::Client.new(graph)
  res_helper = ResourceHelper.new(sparql)

  context "template mapper from RdfPageData" do
    setup do
      @resources_to_templates = {
        "http://www.ifi.uio.no/INF3580/simpsons#Lisa" => "Lisa",
        "http://placeholder.host.plh/placeholder#Placeholder" => "Placeholder"
        }
      @classes_to_templates = {
        "http://xmlns.com/foaf/0.1/Person" => "Person",
        "http://pcai042.informatik.uni-leipzig.de/~dtp16#SpecialPerson" => "SpecialPerson",
        "http://pcai042.informatik.uni-leipzig.de/~dtp16#AnotherSpecialPerson" => "AnotherSpecialPerson"
      }
      @default_template = "default"
    end

    should "return the correct template to a passed resource" do
      @mapper = Jekyll::RdfTemplateMapper.new(@resources_to_templates, @classes_to_templates, @default_template, sparql)
      resource = res_helper.basic_resource("http://www.ifi.uio.no/INF3580/simpsons#Lisa")
      resource2 = res_helper.basic_resource("http://www.ifi.uio.no/INF3580/simpsons#Maggie")
      map_template(resource, @mapper)
      assert_equal("Lisa", @template)
      map_template(resource2, @mapper)
      assert_equal("Person", @template) #No more extensive testing since that is covered by test_rdf_template_mapper
    end

    should "set a flag if it fails to map a template" do
      @mapper = Jekyll::RdfTemplateMapper.new(@resources_to_templates, @classes_to_templates, nil, sparql)
      resource = res_helper.basic_resource("htt://dasfhlösa")
      map_template(resource, @mapper)
      assert_equal(false, @complete)
    end
  end

  context "load_data form RdfPageData" do
    should "load data correctly into the file" do
      res_helper.monkey_patch_page_data(self)
      subresources = ["http://subres1", "http://subres2", "http://subres3"]
      @base = SOURCE_DIR = File.join(File.dirname(__FILE__), "source")
      @resource = res_helper.resource_with_subresources("http://www.ifi.uio.no/INF3580/simpsons#Homer", subresources)
      @template = "homer.html"
      load_data(nil)

      assert_equal("http://www.ifi.uio.no/INF3580/simpsons#Homer", self.data["title"])
      assert_equal("http://www.ifi.uio.no/INF3580/simpsons#Homer", self.data["rdf"].to_s)
      assert_equal("Jekyll::Drops::RdfResource", self.data["rdf"].class.to_s)
      assert_equal("homer.html", self.data["template"])
      assert self.data['sub_rdf'].any?{|res| res.to_s.eql? "http://subres1"}, "the testpage did not load the resource http://subres1"
      assert self.data['sub_rdf'].any?{|res| res.to_s.eql? "http://subres2"}, "the testpage did not load the resource http://subres2"
      assert self.data['sub_rdf'].any?{|res| res.to_s.eql? "http://subres3"}, "the testpage did not load the resource http://subres3"
    end
  end

  context "load_prefixes form RdfPageData" do
    setup do
      subresources = ["http://subres1", "http://subres2", "http://subres3"]
      @resource = res_helper.resource_with_subresources("http://www.ifi.uio.no/INF3580/simpsons#Homer", subresources)
      @base = SOURCE_DIR = File.join(File.dirname(__FILE__), "source")
    end

    should "should map prefixes from the file given through rdf_prefix_path in target templates frontmatter" do
      res_helper.monkey_patch_page_data(self)
      self.read_yaml "arg1", "arg2"
      load_prefixes
      assert_equal "http://www.w3.org/1999/02/22-rdf-syntax-ns#", self.data["rdf_prefix_map"]["rdf"]
      assert_equal "http://www.w3.org/2000/01/rdf-schema#", self.data["rdf_prefix_map"]["rdfs"]
      assert_equal "http://www.w3.org/2001/XMLSchema#", self.data["rdf_prefix_map"]["xsd"]
      assert_equal "http://xmlns.com/foaf/0.1/", self.data["rdf_prefix_map"]["foaf"]
      assert_equal "http://www.ifi.uio.no/INF3580/family#", self.data["rdf_prefix_map"]["fam"]
      assert_equal "http://www.ifi.uio.no/INF3580/simpsons#", self.data["rdf_prefix_map"]["sim"]
      assert_equal "http://pcai042.informatik.uni-leipzig.de/~dtp16#", self.data["rdf_prefix_map"]["dtp16"]
    end

    should "raise an error if the given prefixfile is not accessible" do
      res_helper.monkey_patch_wrong_page_data(self)
      self.read_yaml "arg1", "arg2"
      load_prefixes
      assert Jekyll.logger.messages.any?{|message| !!(message=~ /\s*context: .*  template: .* file not found: .*\s*/)}, "missing error message: context: ****  template: **** file not found: ****"
    end
  end

  context "RdfPageData" do
    setup do
      @resources_to_templates = {
        "http://www.ifi.uio.no/INF3580/simpsons#Homer" => "homer.html",
        "http://placeholder.host.plh/placeholder#Placeholder" => "Placeholder"
        }
      @classes_to_templates = {
        "http://xmlns.com/foaf/0.1/Person" => "person.html",
        "http://pcai042.informatik.uni-leipzig.de/~dtp16#SpecialPerson" => "SpecialPerson",
        "http://pcai042.informatik.uni-leipzig.de/~dtp16#AnotherSpecialPerson" => "AnotherSpecialPerson"
      }
      @default_template = "default.html"
      res_helper.global_site = true
      @resource1 = res_helper.basic_resource("http://www.ifi.uio.no/INF3580/simpsons#Homer")
      @resource2 = res_helper.basic_resource("http://www.ifi.uio.no/INF3580/simpsons#Maggie")
      @resource3 = res_helper.basic_resource("http://resource3")
      res_helper.global_site = false
      @mapper = Jekyll::RdfTemplateMapper.new(@resources_to_templates, @classes_to_templates, @default_template, sparql)
    end

    should "create complete Page" do
      #config = res_helper.basic_config("http://www.ifi.uio.no", "/INF3580")
      config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
      site = Jekyll::Site.new(config)
      site.data['resources'] = []
      page1 = Jekyll::RdfPageData.new(site, File.join(File.dirname(__FILE__), "source"), @resource1, @mapper, config)
      page2 = Jekyll::RdfPageData.new(site, File.join(File.dirname(__FILE__), "source"), @resource2, @mapper, config)
      page3 = Jekyll::RdfPageData.new(site, File.join(File.dirname(__FILE__), "source"), @resource3, @mapper, config)
      assert_equal "http://www.ifi.uio.no/INF3580/simpsons#Homer", @resource1.site.data['resources'][0].to_s
      assert_equal "http://www.ifi.uio.no/INF3580/simpsons#Maggie",  @resource1.site.data['resources'][1].to_s
      assert_equal "http://resource3", @resource1.site.data['resources'][2].to_s
    end

    should "exit early if no base is provided" do
      config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
      site = Jekyll::Site.new(config)
      site.data['resources'] = []
      page1 = Jekyll::RdfPageData.new(site, nil, @resource1, @mapper, config)
      assert !page1.complete, "exit parameter was expected to be false, but it is true"
    end
  end

  context "Jekyll::Drops::RdfResource.render_path with empty baseurl"do
    setup do
      @config = Jekyll.configuration({'url' => "http://ex.org", 'baseurl' => "" })
      @site = Jekyll::Site.new(@config)
    end

    should "correctly render simple urls" do
      assert_equal "/a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/a"), @site).render_path
      assert_equal "/a", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/a"), @site).page_url
      assert_equal "/b/index.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/b/"), @site).render_path
      assert_equal "/b/", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/b/"), @site).page_url
      assert_equal "/b/x.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/b/x"), @site).render_path
      assert_equal "/b/x", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/b/x"), @site).page_url
      assert_equal "/b/y/index.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/b/y/"), @site).render_path
      assert_equal "/b/y/", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/b/y/"), @site).page_url
      assert_equal "/a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/a.html"), @site).render_path
      assert_equal "/a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/a.html"), @site).page_url
    end

    should "let fragment-identifier default to super resource" do
      assert_equal "/c.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/c#alpha"), @site).render_path
      assert_equal "/c#alpha", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/c#alpha"), @site).page_url
      assert_equal "/c.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/c#beta"), @site).render_path
      assert_equal "/c#beta", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/c#beta"), @site).page_url
    end
  end

  context "Jekyll::Drops::RdfResource.render_path with '/' as baseurl"do
    setup do
      @config = Jekyll.configuration({'url' => "http://ex.org", 'baseurl' => "/" })
      @site = Jekyll::Site.new(@config)
    end

    should "correctly render simple urls" do
      assert_equal "a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/a"), @site).render_path
      assert_equal "a", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/a"), @site).page_url
      assert_equal "b/index.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/b/"), @site).render_path
      assert_equal "b/", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/b/"), @site).page_url
      assert_equal "b/x.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/b/x"), @site).render_path
      assert_equal "b/x", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/b/x"), @site).page_url
      assert_equal "b/y/index.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/b/y/"), @site).render_path
      assert_equal "b/y/", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/b/y/"), @site).page_url
      assert_equal "a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/a.html"), @site).render_path
      assert_equal "a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/a.html"), @site).page_url
    end

    should "let fragment-identifier default to super resource" do
      assert_equal "c.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/c#alpha"), @site).render_path
      assert_equal "c#alpha", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/c#alpha"), @site).page_url
      assert_equal "c.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/c#beta"), @site).render_path
      assert_equal "c#beta", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/c#beta"), @site).page_url
    end
  end

  context "Jekyll::Drops::RdfResource.render_path with subdirectory baseurl"do
    setup do
      @config = Jekyll.configuration({'url' => "http://ex.org", 'baseurl' => "/blog" })
      @site = Jekyll::Site.new(@config)
    end

    should "correctly render simple urls" do
      assert_equal "/bla/a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/bla/a"), @site).render_path
      assert_equal "/rdfsites/http/ex.org/bla/blog/a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/bla/blog/a"), @site).render_path
      assert_equal "/rdfsites/http/ex.org/a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/a"), @site).render_path
      assert_equal "/rdfsites/http/ex.org/a", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/a"), @site).page_url
      assert_equal "/a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a"), @site).render_path
      assert_equal "/a", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a"), @site).page_url
      assert_equal "/b/index.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/"), @site).render_path
      assert_equal "/b/", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/"), @site).page_url
      assert_equal "/b/x.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/x"), @site).render_path
      assert_equal "/b/x", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/x"), @site).page_url
      assert_equal "/b/y/index.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/y/"), @site).render_path
      assert_equal "/b/y/", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/y/"), @site).page_url
      assert_equal "/a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a.html"), @site).render_path
      assert_equal "/a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a.html"), @site).page_url
    end

    should "let fragment-identifier default to super resource" do
      assert_equal "/c.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#alpha"), @site).render_path
      assert_equal "/c#alpha", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#alpha"), @site).page_url
      assert_equal "/c.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#beta"), @site).render_path
      assert_equal "/c#beta", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#beta"), @site).page_url
    end
  end

  context "Jekyll::Drops::RdfResource.render_path with subdirectory baseurl ending with slash"do
    setup do
      @config = Jekyll.configuration({'url' => "http://ex.org", 'baseurl' => "/blog/" })
      @site = Jekyll::Site.new(@config)
    end

    should "correctly render simple urls" do
      assert_equal "bla/a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/bla/a"), @site).render_path
      assert_equal "rdfsites/http/ex.org/bla/blog/a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/bla/blog/a"), @site).render_path
      assert_equal "rdfsites/http/ex.org/a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/a"), @site).render_path
      assert_equal "rdfsites/http/ex.org/a", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/a"), @site).page_url
      assert_equal "a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a"), @site).render_path
      assert_equal "a", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a"), @site).page_url
      assert_equal "b/index.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/"), @site).render_path
      assert_equal "b/", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/"), @site).page_url
      assert_equal "b/x.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/x"), @site).render_path
      assert_equal "b/x", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/x"), @site).page_url
      assert_equal "b/y/index.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/y/"), @site).render_path
      assert_equal "b/y/", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/y/"), @site).page_url
      assert_equal "a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a.html"), @site).render_path
      assert_equal "a.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a.html"), @site).page_url
    end

    should "let fragment-identifier default to super resource" do
      assert_equal "c.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#alpha"), @site).render_path
      assert_equal "c#alpha", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#alpha"), @site).page_url
      assert_equal "c.html", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#beta"), @site).render_path
      assert_equal "c#beta", Jekyll::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#beta"), @site).page_url
    end
  end
end
