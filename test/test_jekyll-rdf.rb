require 'test_helper'

class TestJekyllRdf < Test::Unit::TestCase
  include RSpec::Matchers
  config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
  site = Jekyll::Site.new(config)
  site.process
  pagearray = site.pages.select{|p|
    p.name == "simpsons/index.html".gsub(TestHelper::BASE_URL, '')
  } # creates an array
  simpson_page = pagearray[0] # select first entry of selection
  context "Generating a site with RDF data" do
    should "create a file which mentions 'Lisa Simpson'" do
      s = File.read("#{TestHelper::DEST_DIR}/INF3580/simpsons/index.html") # read static file
      expect(s).to include 'http://www.ifi.uio.no/INF3580/simpsons#Lisa'
    end

    should "create a file which lists through rdf_property Homers jobs" do
      s = File.read("#{TestHelper::DEST_DIR}/INF3580/simpsons/index.html") # read static file
      expect(s).to include "unknown Job 2"
    end

    should "create a file for http://pcai042.informatik.uni-leipzig.de/~dtp16/#TestPersonMagrid" do
      s = File.read("#{TestHelper::DEST_DIR}/INF3580/rdfsites/http/pcai042.informatik.uni-leipzig.de/~dtp16/#/TestPersonMagrid/index.html")
      expect(s).to include "http://pcai042.informatik.uni-leipzig.de/~dtp16/#TestPersonMagrid"
      assert Jekyll.logger.messages.any? {|message| message.strip.eql? "classMapped: http://pcai042.informatik.uni-leipzig.de/~dtp16/#MagridsSpecialClass : http://pcai042.informatik.uni-leipzig.de/~dtp16/#TestPersonMagrid : person.html"}
      assert Jekyll.logger.messages.any? {|message| message.strip.eql? "Warning: multiple possible templates for http://pcai042.informatik.uni-leipzig.de/~dtp16/#TestPersonMagrid: person.html"}
    end
  end

  context "Generate a page from RDF data" do
    should "have rdf data" do
      assert_not_nil(simpson_page.data['rdf'])
    end
  end

  include Jekyll::RdfProperty
  include Jekyll::RdfSparqlQuery
  context "Generate a rdf_resource Homer that" do
    homer_resource = simpson_page.data['sub_rdf'].find{|res| res.iri == 'http://www.ifi.uio.no/INF3580/simpsons#Homer'}

    should "contain correct age of Homer Simpson" do
      plain_statements =  homer_resource.statements.map{|statement| [statement.subject.to_s, statement.predicate.to_s, statement.object.to_s]}
      assert plain_statements.include?(["http://www.ifi.uio.no/INF3580/simpsons#Homer",'http://xmlns.com/foaf/0.1/age','36'])
    end

    should "have no job listed with the language tag 'chk'" do
      assert (rdf_property(homer_resource, "<http://xmlns.com/foaf/0.1/job>", "chk", false)).nil?
    end

    should "be part of the Simpsons family" do
      puts "test inverse properties #{ rdf_inverse_property(homer_resource, "<http://www.ifi.uio.no/INF3580/family#hasFamilyMember>", nil, false)}"
      assert_equal(rdf_inverse_property(homer_resource, "<http://www.ifi.uio.no/INF3580/family#hasFamilyMember>", nil, false).to_s, "http://www.ifi.uio.no/INF3580/simpsons#TheSimpsons")
    end

    should "have a job listed with the language tag 'en'" do
      jobString = rdf_property(homer_resource, "<http://xmlns.com/foaf/0.1/job>", "en", false).to_s
      assert ("unknown".eql?(jobString) || "unknown Job 2".eql?(jobString))
    end
  end

  context "The method rdf_property" do
    resource_no_pref_defined = Jekyll::Drops::RdfResource.new("http://thats.a.test.de/path", nil)
    no_pref_page = Object.new
    def no_pref_page.data
      {}
    end
    resource_no_pref_defined.page = no_pref_page
    should "be able to throw a NoPrefixDefined" do
      assert_raise(NoPrefixesDefined) do# Jekyll.logger.messages.any? {|message| !!(message =~ /\s*No Prefixes are defined when .* gets passed in\s*/)}
        rdf_property(resource_no_pref_defined, "sup:that", "chk", false)
      end
    end

    resource_with_pref_defined = Jekyll::Drops::RdfResource.new("http://thats.a.test.de/path", nil)
    with_pref_page = Object.new
    def with_pref_page.data
      {"rdf_prefixes" => {}, "rdf_prefix_map" => {}}
    end
    resource_with_pref_defined.page = with_pref_page
    should "be able to throw a NoPrefixMapped" do
      assert_raise(NoPrefixMapped) do
        rdf_property(resource_with_pref_defined, "sup:that", "chk", false)
      end # Jekyll.logger.messages.any? {|message| !!(message =~ /\s*Their is no mapping defined for .* in context to .*\s*/)}
    end
    should "be able to throw an UnMarkedUri exception" do
      assert_raise(UnMarkedUri) do #Jekyll.logger.messages.any? {|message| !!(message =~ /\s*The URI .* is not correctly marked\. Pls use the form <.*> instead\.\s*/)}
        rdf_property(resource_with_pref_defined, "sup:that:asdf", "chk", false)
      end
    end
  end

  context "rdf_sparql_query" do
    homer_resource = simpson_page.data['sub_rdf'].find{|res| res.iri == 'http://www.ifi.uio.no/INF3580/simpsons#Homer'}

    should "create a result " do
      query = "SELECT ?s WHERE{ ?s fam:hasFather ?resourceUri }"
      result = sparql_query(homer_resource, query)
      assert result.length == 3
      assert result.any? {|s|
        rdf_property(s["s"], '<http://xmlns.com/foaf/0.1/name>').to_s.eql? "Bart Simpson"
      }
    end

    new_homer_resource = homer_resource.clone           #fake objecte um andere tests nicht zu beeinflussen
    fake_sparql_client = homer_resource.site.data["sparql"].clone
    new_homer_resource.site.data["sparql"] = fake_sparql_client

    should "handle a Sparql::Client::Error" do
      def fake_sparql_client.query query
        raise SPARQL::Client::ClientError
      end
      sparql_query(new_homer_resource,"Query")
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /client error experienced:.*/)}
    end

    should "handle a SPARQL::MalformedQuery Error" do
      def fake_sparql_client.query query
        raise SPARQL::MalformedQuery
      end
      sparql_query(new_homer_resource,"Query")
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /malformed query found:.*/)}
    end

    should "handle Exceptions" do
      def fake_sparql_client.query query
        raise Exception
      end
      sparql_query(new_homer_resource,"Query")
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /unknown Exception of class:.*/)}
    end

    should "return an empty array in case of an Exception" do
      def fake_sparql_client.query query
        raise Exception
      end
      result = sparql_query(new_homer_resource,"Query")
      assert result.empty?
    end
  end
end
#test
