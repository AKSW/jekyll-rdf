require 'test_helper'

class TestRdfResource < Test::Unit::TestCase
  context "rdfResource.inspect" do
    setup do
      @resource = Jekyll::JekyllRdf::Drops::RdfResource.new("http://test.this/resource")
      @resourceSubs = Jekyll::JekyllRdf::Drops::RdfResource.new("http://test.this/resource/with/sub/resources")
      @resourceSubs.subResources = [Jekyll::JekyllRdf::Drops::RdfResource.new("http://test.this/resource/with/sub/resources1"), Jekyll::JekyllRdf::Drops::RdfResource.new("http://test.this/resource/with/sub/resources2"), Jekyll::JekyllRdf::Drops::RdfResource.new("http://test.this/resource/with/sub/resources3"), Jekyll::JekyllRdf::Drops::RdfResource.new("http://test.this/resource/with/sub/resources4"), Jekyll::JekyllRdf::Drops::RdfResource.new("http://test.this/resource/with/sub/resources5"), Jekyll::JekyllRdf::Drops::RdfResource.new("http://test.this/resource/with/sub/resources6")]
    end
    should "return the ruby object_id and iri of the rdf-resource" do
      assert_equal "#<RdfResource:0x", @resource.inspect[0..15]
      assert_equal "@iri=http://test.this/resource @subResources=[]>", @resource.inspect[31..-1]
    end

    should "return the inspect representation together with the inspect representations of its subresources" do
      assert !/#<RdfResource:0x(\d|[a-f]){14} @iri=((?!@subResources).)+ @subResources=\[(#<RdfResource:0x(\d|[a-f]){14} @iri=((?!@subResources).)+ @subResources=\[\]>(,\s){0,1}){6}\]>/.match(@resourceSubs.inspect).nil?, "Output string of inspect does not match regex /#<RdfResource:0x(\d|[a-f]){14} @iri=((?!@subResources).)+ @subResources=\[(#<RdfResource:0x(\d|[a-f]){14} @iri=((?!@subResources).)+ @subResources=\[\]>(,\s){0,1}){6}\]>/"
    end
  end

  context "RdfTerm.inspect" do
    setup do
      @literal = Jekyll::JekyllRdf::Drops::RdfLiteral.new("http://a.random/literal")
      @term = Jekyll::JekyllRdf::Drops::RdfTerm.new("http://a.random/term")
    end
    should "return the class, the object_id and the term of this object" do
      assert_equal "#<RdfLiteral:0x", @literal.inspect[0..14]
      assert_equal "@term=http://a.random/literal>", @literal.inspect[30..-1]
      assert_equal "#<RdfTerm:0x", @term.inspect[0..11]
      assert_equal "@term=http://a.random/term>", @term.inspect[27..-1]
    end
  end

  context "RdfStatement.inspect" do
    setup do
      @statement = Jekyll::JekyllRdf::Drops::RdfStatement.new(RDF::Statement(RDF::URI("http://example.resource/subject"), RDF::Node("http://example.term/predicate"), RDF::Literal("http://example.literal/object")), Object.new)
    end
    should "return the class, the object_id and the term of this object" do
      assert_equal "#<RdfStatement:0x", @statement.inspect[0..16]
      assert_equal "@subject=#<RdfResource:0x", @statement.inspect[32..56]
      assert_equal "@iri=http://example.resource/subject @subResources=[]> @predicate=#<RdfResource:0x", @statement.inspect[72..153]
      assert_equal "@iri= @subResources=[]> @object=#<RdfLiteral:0x", @statement.inspect[169..215]
      assert_equal "@term=http://example.literal/object>>", @statement.inspect[231..298]
    end
  end

  context "RdfTerm comparisions" do
    setup do
      @compare_term = Jekyll::JekyllRdf::Drops::RdfTerm.new(RDF::URI("http://www.ifi.uio.no/INF3580/main"))
    end

    should "recognize to completly equal terms" do
      assert (@compare_term.eql? Jekyll::JekyllRdf::Drops::RdfTerm.new(RDF::URI("http://www.ifi.uio.no/INF3580/main"))), ".eql? does not recognize equality"
      assert (@compare_term == Jekyll::JekyllRdf::Drops::RdfTerm.new(RDF::URI("http://www.ifi.uio.no/INF3580/main"))), "== does not recognize equality"
      assert (@compare_term === Jekyll::JekyllRdf::Drops::RdfTerm.new(RDF::URI("http://www.ifi.uio.no/INF3580/main"))), "=== does not recognize equality"
    end

    should "recognize differences" do
      current_term = Jekyll::JekyllRdf::Drops::RdfTerm.new(RDF::URI("http://www.ifi.uio.no/INF3580/main2"))
      assert !(@compare_term.eql? current_term), "RdfTerm comparisons do not find the difference between the iris #{@compare_term} and #{current_term}"
    end

    class TestURI < RDF::URI

    end

    class TestResource < Jekyll::JekyllRdf::Drops::RdfTerm

    end

    class RandomClass
      def to_s
        "http://www.ifi.uio.no/INF3580/main"
      end
    end

    should "let .eql? recognize other objects across classes" do
      compare_uri = TestURI.new("http://www.ifi.uio.no/INF3580/main")
      compare_resource = Jekyll::JekyllRdf::Drops::RdfResource.new("http://www.ifi.uio.no/INF3580/main")
      compare_object = RandomClass.new()
      assert (@compare_term === "http://www.ifi.uio.no/INF3580/main"), "=== should see equality between term: #{@compare_term} and \"http://www.ifi.uio.no/INF3580/main\""
      assert (@compare_term.eql? compare_uri), ".eql? should see equality between term: #{@compare_term}  class: #{@compare_term.class} and term: #{compare_uri} class: #{compare_uri.class}"
      assert (@compare_term.eql? compare_resource), ".eql? should see equality between term: #{@compare_term}  class: #{@compare_term.class} and term: #{compare_resource} class: #{compare_resource.class}"
      assert (compare_resource.eql? @compare_term ), ".eql? should see equality between term: #{compare_resource} class: #{compare_resource.class} and term: #{@compare_term}  class: #{@compare_term.class}"
      assert !(@compare_term.eql? compare_object), ".eql? not should not see equality between term: #{@compare_term}  class: #{@compare_term.class} and term: #{compare_object} class: #{compare_object.class}"
    end

    should "let === handle to_s implementing Objects" do
      current_term = Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://www.ifi.uio.no/INF3580/main"))
      assert (@compare_term === current_term), "RdfTerm comparisons should see equality between #{@compare_term} class: #{@compare_term.class} and #{current_term} class: #{current_term.class}"
      current_term = Jekyll::JekyllRdf::Drops::RdfResource.new("http://www.ifi.uio.no/INF3580/main")
      assert (@compare_term === current_term), "RdfTerm comparisons should see equality between #{@compare_term} class: #{@compare_term.class} and #{current_term} class: #{current_term.class}"
      current_term = Jekyll::JekyllRdf::Drops::RdfResource.new("http://www.ifi.uio.no/INF3580/main")
      current_term_2 = Jekyll::JekyllRdf::Drops::RdfTerm.new(RDF::URI("http://www.ifi.uio.no/INF3580/main"))
      assert (current_term === current_term_2), "RdfTerm comparisons should see equality between #{current_term} class: #{current_term.class} and #{current_term_2} class: #{current_term_2.class}"
    end
  end

  context "Jekyll::JekyllRdf::Drops::RdfResource.render_path with empty baseurl" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper::domainiri = "http://ex.org"
      Jekyll::JekyllRdf::Helper::RdfHelper::pathiri = ""
    end

    should "correctly render simple urls" do
      assert_equal "/a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/a")).render_path
      assert_equal "/a", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/a")).page_url
      assert_equal "/b/index.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/b/")).render_path
      assert_equal "/b/", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/b/")).page_url
      assert_equal "/b/x.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/b/x")).render_path
      assert_equal "/b/x", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/b/x")).page_url
      assert_equal "/b/y/index.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/b/y/")).render_path
      assert_equal "/b/y/", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/b/y/")).page_url
      assert_equal "/a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/a.html")).render_path
      assert_equal "/a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/a.html")).page_url
    end

    should "let fragment-identifier default to super resource" do
      assert_equal "/c.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/c#alpha")).render_path
      assert_equal "/c#alpha", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/c#alpha")).page_url
      assert_equal "/c.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/c#beta")).render_path
      assert_equal "/c#beta", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/c#beta")).page_url
    end
  end

  context "Jekyll::JekyllRdf::Drops::RdfResource.render_path with '/' as baseurl"do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper::domainiri = "http://ex.org"
      Jekyll::JekyllRdf::Helper::RdfHelper::pathiri = "/"
    end

    should "correctly render simple urls" do
      assert_equal "a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/a")).render_path
      assert_equal "a", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/a")).page_url
      assert_equal "b/index.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/b/")).render_path
      assert_equal "b/", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/b/")).page_url
      assert_equal "b/x.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/b/x")).render_path
      assert_equal "b/x", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/b/x")).page_url
      assert_equal "b/y/index.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/b/y/")).render_path
      assert_equal "b/y/", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/b/y/")).page_url
      assert_equal "a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/a.html")).render_path
      assert_equal "a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/a.html")).page_url
    end

    should "let fragment-identifier default to super resource" do
      assert_equal "c.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/c#alpha")).render_path
      assert_equal "c#alpha", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/c#alpha")).page_url
      assert_equal "c.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/c#beta")).render_path
      assert_equal "c#beta", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/c#beta")).page_url
    end
  end

  context "Jekyll::JekyllRdf::Drops::RdfResource.render_path with subdirectory baseurl"do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper::domainiri = "http://ex.org"
      Jekyll::JekyllRdf::Helper::RdfHelper::pathiri = "/blog"
    end

    should "correctly render simple urls" do
      assert_equal "/bla/a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/bla/a")).render_path
      assert_equal "/rdfsites/http/ex.org/bla/blog/a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/bla/blog/a")).render_path
      assert_equal "/rdfsites/http/ex.org/a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/a")).render_path
      assert_equal "/rdfsites/http/ex.org/a", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/a")).page_url
      assert_equal "/a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a")).render_path
      assert_equal "/a", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a")).page_url
      assert_equal "/b/index.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/")).render_path
      assert_equal "/b/", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/")).page_url
      assert_equal "/b/x.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/x")).render_path
      assert_equal "/b/x", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/x")).page_url
      assert_equal "/b/y/index.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/y/")).render_path
      assert_equal "/b/y/", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/y/")).page_url
      assert_equal "/a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a.html")).render_path
      assert_equal "/a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a.html")).page_url
    end

    should "let fragment-identifier default to super resource" do
      assert_equal "/c.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#alpha")).render_path
      assert_equal "/c#alpha", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#alpha")).page_url
      assert_equal "/c.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#beta")).render_path
      assert_equal "/c#beta", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#beta")).page_url
    end
  end

  context "Jekyll::JekyllRdf::Drops::RdfResource.render_path with subdirectory baseurl ending with slash"do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper::domainiri = "http://ex.org"
      Jekyll::JekyllRdf::Helper::RdfHelper::pathiri = "/blog/"
    end

    should "correctly render simple urls" do
      assert_equal "bla/a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/bla/a")).render_path
      assert_equal "rdfsites/http/ex.org/bla/blog/a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/bla/blog/a")).render_path
      assert_equal "rdfsites/http/ex.org/a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/a")).render_path
      assert_equal "rdfsites/http/ex.org/a", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/a")).page_url
      assert_equal "a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a")).render_path
      assert_equal "a", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a")).page_url
      assert_equal "b/index.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/")).render_path
      assert_equal "b/", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/")).page_url
      assert_equal "b/x.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/x")).render_path
      assert_equal "b/x", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/x")).page_url
      assert_equal "b/y/index.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/y/")).render_path
      assert_equal "b/y/", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/b/y/")).page_url
      assert_equal "a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a.html")).render_path
      assert_equal "a.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/a.html")).page_url
    end

    should "let fragment-identifier default to super resource" do
      assert_equal "c.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#alpha")).render_path
      assert_equal "c#alpha", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#alpha")).page_url
      assert_equal "c.html", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#beta")).render_path
      assert_equal "c#beta", Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://ex.org/blog/c#beta")).page_url
    end
  end

  context "RdfResource" do
    should "correctly disect its iri into file name and file directory" do
      resource = Jekyll::JekyllRdf::Drops::RdfResource.new("http://ex.org/blog/bla/a")
      Jekyll::JekyllRdf::Helper::RdfHelper::domainiri = "http://ex.org"
      Jekyll::JekyllRdf::Helper::RdfHelper::pathiri = "/blog/"
      assert_equal "a.html", resource.filename
      assert_equal "bla/", resource.filedir
      resource = Jekyll::JekyllRdf::Drops::RdfResource.new("http://ex.org/blog/bla/a")
      Jekyll::JekyllRdf::Helper::RdfHelper::domainiri = "http://ex.org"
      Jekyll::JekyllRdf::Helper::RdfHelper::pathiri = ""
      assert_equal "a.html", resource.filename
      assert_equal "/blog/bla/", resource.filedir
    end

    should "set the filedir to rdfsites/... if the site url and baseurl coincides with the resource iri" do
      resource = Jekyll::JekyllRdf::Drops::RdfResource.new("http://ex.org/blog/bla/a")
      Jekyll::JekyllRdf::Helper::RdfHelper::domainiri = ""
      Jekyll::JekyllRdf::Helper::RdfHelper::pathiri = ""
      assert_equal "a.html", resource.filename
      assert_equal "/rdfsites/http/ex.org/blog/bla/", resource.filedir
      resource = Jekyll::JekyllRdf::Drops::RdfResource.new("http://ex.org/blog/bla/a")
      Jekyll::JekyllRdf::Helper::RdfHelper::domainiri = "http://ex.org"
      Jekyll::JekyllRdf::Helper::RdfHelper::pathiri = "t"
      assert_equal "a.html", resource.filename
      assert_equal "/rdfsites/http/ex.org/blog/bla/", resource.filedir
      resource = Jekyll::JekyllRdf::Drops::RdfResource.new("http://ex.org/blog/bla/a")
      Jekyll::JekyllRdf::Helper::RdfHelper::domainiri = "http://ex.org"
      Jekyll::JekyllRdf::Helper::RdfHelper::pathiri = "/blog/s"
      assert_equal "a.html", resource.filename
      assert_equal "/rdfsites/http/ex.org/blog/bla/", resource.filedir
    end
  end

  context "Jekyll::JekyllRdf::Drops::RdfResource" do
    should "return the iri on calling .iri" do
      resource = Jekyll::JekyllRdf::Drops::RdfResource.new("http://example.org/instance/resource")
      assert_equal "http://example.org/instance/resource", resource.iri
      blank_node = Jekyll::JekyllRdf::Drops::RdfResource.new("_:123456789")
      assert_equal "", blank_node.iri
      blank_node = Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::Node.new)
      assert_equal "", blank_node.iri
    end

    should "distinguish between resources and blanknodes" do
      resource = Jekyll::JekyllRdf::Drops::RdfResource.new("http://example.org/instance/resource")
      assert !resource.blank?, "The resource #{resource} is not a blanknode"
      blank_node = Jekyll::JekyllRdf::Drops::RdfResource.new("_:123456789")
      assert blank_node.blank?, "The resource #{blank_node} is a blanknode"
      blank_node = Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::Node.new)
      assert blank_node.blank?, "The resource #{blank_node} is a blanknode"
    end
  end
end