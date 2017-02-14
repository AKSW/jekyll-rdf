require 'test_helper'
require 'pp'
#require 'RdfProperty'

class TestJekyllRdf < Test::Unit::TestCase
  include RSpec::Matchers

  config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
  site = Jekyll::Site.new(config)
  site.process
  pagearray = site.pages.select{|p|
    p.name == "INF3580/simpsons/index.html".gsub(TestHelper::BASE_URL, '')
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
      s = File.read("#{TestHelper::DEST_DIR}/rdfsites/http/pcai042.informatik.uni-leipzig.de/~dtp16/_/#/TestPersonMagrid/index.html")
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
    homer_resource = simpson_page.data['sub_rdf'].find{|res| res.name == 'http://www.ifi.uio.no/INF3580/simpsons#Homer'} #needs to be adjusted to http://www.ifi.uio.no/INF3580/simpsons#Homer when branch gets merged with Fix_Wrong_Naming_Issue

    should "contain correct age of Homer Simpson" do
      plain_statements =  homer_resource.statements.map{|statement| [statement.subject.to_s, statement.predicate.to_s, statement.object.to_s]}
      assert plain_statements.include?(["http://www.ifi.uio.no/INF3580/simpsons#Homer",'http://xmlns.com/foaf/0.1/age','36'])
    end

    should "have no job listed with the language tag 'chk'" do
      assert (rdf_property(homer_resource, "<http://xmlns.com/foaf/0.1/job>", "chk", false)).nil?
    end

    should "have a job listed with the language tag 'en'" do
      assert rdf_property(homer_resource, "<http://xmlns.com/foaf/0.1/job>", "en", false) == "unknown"
    end
  end

  context "rdf_sparql_query" do
    homer_resource = simpson_page.data['sub_rdf'].find{|res| res.name == 'http://www.ifi.uio.no/INF3580/simpsons#Homer'} #needs to be adjusted to http://www.ifi.uio.no/INF3580/simpsons#Homer when branch gets merged with Fix_Wrong_Naming_Issue

    should "create a result " do
      query = "SELECT ?s WHERE{ ?s fam:hasFather ?resourceUri }"
      result = sparql_query(homer_resource, query)
      assert result.length == 3
      assert result.any? {|s|
        rdf_property(s["s"], '<http://xmlns.com/foaf/0.1/name>') == "Bart Simpson"
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
