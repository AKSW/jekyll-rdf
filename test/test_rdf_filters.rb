require 'test_helper'

class TestRdfFilter < Test::Unit::TestCase
  include Jekyll::RdfProperty
  include Jekyll::RdfCollection
  include Jekyll::RdfContainer
  include Jekyll::RdfPrefixResolver
  include Jekyll::RdfSparqlQuery
  graph = RDF::Graph.load(TestHelper::TEST_OPTIONS['jekyll_rdf']['path'])
  sparql = SPARQL::Client.new(graph)
  res_helper = ResourceHelper.new(sparql)
  context "Filter rdf_property from Jekyll::RdfProperty" do
    setup do
      prefixes = {"rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdfs" => "http://www.w3.org/2000/01/rdf-schema#", "foaf" => "http://xmlns.com/foaf/0.1/", "fam" => "http://www.ifi.uio.no/INF3580/family#"}
      @testResource = res_helper.resource_with_prefixes_config("http://www.ifi.uio.no/INF3580/simpsons#Homer", prefixes)
    end

    should "return the correct URI" do
      answer = rdf_property(@testResource, "<http://www.ifi.uio.no/INF3580/family#hasSpouse>")
      assert_equal(answer.to_s, "http://www.ifi.uio.no/INF3580/simpsons#Marge")
    end

    should "return the correct URI when prefixes are used" do
      answer = rdf_property(@testResource, "fam:hasSpouse")
      assert_equal(answer.to_s, "http://www.ifi.uio.no/INF3580/simpsons#Marge")
    end

    should "return a list of properties when 'list' parameter is set" do
      answer = rdf_property(@testResource, "foaf:job", nil, true)
      assert(answer.is_a?(Array))
      assert(answer.any? {|resource| resource.to_s.eql? "unknown"})
      assert(answer.any? {|resource| resource.to_s.eql? "unbekannt"})
      assert(answer.any? {|resource| resource.to_s.eql? "unbekannter Job 2"})
      assert(answer.any? {|resource| resource.to_s.eql? "unknown Job 2"})
    end

    should "return a list of properties from specified language" do
      answer = rdf_property(@testResource, "foaf:job", 'en', true)
      assert(answer.is_a?(Array))
      assert(answer.any? {|resource| resource.to_s.eql? "unknown"})
      assert(!answer.any? {|resource| resource.to_s.eql? "unbekannt"})
      assert(!answer.any? {|resource| resource.to_s.eql? "unbekannter Job 2"})
      assert(answer.any? {|resource| resource.to_s.eql? "unknown Job 2"})
    end

    should "return a list of properties from in a config specified language" do
      answer = rdf_property(@testResource, "foaf:job", 'cfg', true)
      assert(answer.is_a?(Array))
      assert(answer.any? {|resource| resource.to_s.eql? "unknown"})
      assert(!answer.any? {|resource| resource.to_s.eql? "unbekannt"})
      assert(!answer.any? {|resource| resource.to_s.eql? "unbekannter Job 2"})
      assert(answer.any? {|resource| resource.to_s.eql? "unknown Job 2"})
    end

    should "be reversable with all specifications" do
      answer = rdf_inverse_property(@testResource, "fam:hasFather", nil, true)
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Bart"})
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Lisa"})
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Maggie"})
    end
  end

  context "Filter sparql_query from Jekyll::RdfSparqlQuery" do
    setup do
      prefixes = {"rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdfs" => "http://www.w3.org/2000/01/rdf-schema#", "foaf" => "http://xmlns.com/foaf/0.1/", "fam" => "http://www.ifi.uio.no/INF3580/family#"}
      @testResource = res_helper.resource_with_prefixes_config("http://www.ifi.uio.no/INF3580/simpsons#Homer", prefixes)
    end

    should "return an array of solutions to one query" do
      query = "SELECT ?x ?y WHERE{ ?x <http://www.ifi.uio.no/INF3580/family#hasFather> ?y}"
      answer = sparql_query(@testResource, query)
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://www.ifi.uio.no/INF3580/simpsons#Bart') && (solution['y'].to_s.eql?  'http://www.ifi.uio.no/INF3580/simpsons#Homer')})
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://www.ifi.uio.no/INF3580/simpsons#Lisa') && (solution['y'].to_s.eql?  'http://www.ifi.uio.no/INF3580/simpsons#Homer')})
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://www.ifi.uio.no/INF3580/simpsons#Maggie') && (solution['y'].to_s.eql?  'http://www.ifi.uio.no/INF3580/simpsons#Homer')})
    end

    should "return an array of solutions to one query with prefixes" do
      query = "SELECT ?x ?y WHERE{ ?x fam:hasFather ?y}"
      answer = sparql_query(@testResource, query)
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://www.ifi.uio.no/INF3580/simpsons#Bart') && (solution['y'].to_s.eql?  'http://www.ifi.uio.no/INF3580/simpsons#Homer')})
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://www.ifi.uio.no/INF3580/simpsons#Lisa') && (solution['y'].to_s.eql?  'http://www.ifi.uio.no/INF3580/simpsons#Homer')})
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://www.ifi.uio.no/INF3580/simpsons#Maggie') && (solution['y'].to_s.eql?  'http://www.ifi.uio.no/INF3580/simpsons#Homer')})
    end

    should "return the literal if a literal was passed as first argument" do
      literal = res_helper.basic_literal("basic")
      query = "TEST"
      answer = sparql_query(literal, query)
      assert(literal.to_s.eql? answer.to_s)
    end

    # These 3 tests are prune to errors if rdf_resource changes to use sparql in its setup process
    should "log a SPARQL::Client::ClientError Exception" do
      resource = res_helper.resource_faulty_sparql("http://www.ifi.uio.no/INF3580/simpsons#Homer", :ClientError)
      query = "SELECT ?x ?y WHERE{ ?x <http://www.ifi.uio.no/INF3580/family#hasFather> ?y}"
      sparql_query(resource, query)
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /client error experienced:.*/)}
    end

    should "log a SPARQL::MalformedQuery Exception" do
      resource = res_helper.resource_faulty_sparql("http://www.ifi.uio.no/INF3580/simpsons#Homer", :MalformedQuery)
      query = "SELECT ?x ?y WHERE{ ?x <http://www.ifi.uio.no/INF3580/family#hasFather> ?y}"
      sparql_query(resource, query)
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /client error experienced:.*/)}
    end

    should "log a basic Exception if an unknown exception occurs" do
      resource = res_helper.resource_faulty_sparql("http://www.ifi.uio.no/INF3580/simpsons#Homer", :Exception)
      query = "SELECT ?x ?y WHERE{ ?x <http://www.ifi.uio.no/INF3580/family#hasFather> ?y}"
      sparql_query(resource, query)
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /client error experienced:.*/)}
    end
  end

  context "rdf_resolve_prefix from Jekyll::RdfPrefixResolver" do
    setup do
      prefixes = {"rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdfs" => "http://www.w3.org/2000/01/rdf-schema#", "foaf" => "http://xmlns.com/foaf/0.1/", "fam" => "http://www.ifi.uio.no/INF3580/family#"}
      @testResource = res_helper.resource_with_prefixes_config("http://www.ifi.uio.no/INF3580/simpsons#Homer", prefixes)
    end

    should "resolve the prefix foaf to its full length" do
      answer = rdf_resolve_prefix(@testResource, 'foaf:name')
      assert_equal(answer, "http://xmlns.com/foaf/0.1/name")
    end

    should "return the uri of any correctly marked uri" do
      answer = rdf_resolve_prefix(@testResource, '<http://xmlns.com/foaf/0.1/name>')
      assert_equal(answer, 'http://xmlns.com/foaf/0.1/name')
    end

    should "raise an UnMarkedUri exception if there is a full uri instead of a prefix" do
      assert_raise UnMarkedUri do
        rdf_resolve_prefix(@testResource, 'http://xmlns.com/foaf/0.1/name')
      end
    end

    should "raise a NoPrefixMapped exception if no fitting prefix is found" do
      assert_raise NoPrefixMapped do
        rdf_resolve_prefix(@testResource, 'foae:name')
      end
    end

    should "raise a NoPrefixesDefined exception if no prefixes are found" do
      resource = res_helper.basic_resource("test")
      assert_raise NoPrefixesDefined do
        rdf_resolve_prefix(resource, 'foae:name')
      end
    end
  end

  context "Filter rdf_collection from Jekyll::RdfCollection" do
    setup do
      prefixes = {"rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdfs" => "http://www.w3.org/2000/01/rdf-schema#", "foaf" => "http://xmlns.com/foaf/0.1/", "fam" => "http://www.ifi.uio.no/INF3580/family#", "simc" => "http://www.ifi.uio.no/INF3580/simpson-collection#"}
      @testResource = res_helper.resource_with_prefixes_config("http://www.ifi.uio.no/INF3580/simpson-collection#Collection", prefixes)
    end

    should "return a set of resources stashed in the passed collection" do
      answer = rdf_collection(@testResource)
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"})
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Marge"})
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Bart"})
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Lisa"})
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Maggie"})
    end
  end

  context "Filter rdf_container from Jekyll::RdfContainer" do
    setup do
      prefixes = {"rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdfs" => "http://www.w3.org/2000/01/rdf-schema#", "foaf" => "http://xmlns.com/foaf/0.1/", "fam" => "http://www.ifi.uio.no/INF3580/family#", "simcon" => "http://www.ifi.uio.no/INF3580/simpson-container#"}
      @testResource = res_helper.resource_with_prefixes_config("http://www.ifi.uio.no/INF3580/simpson-container#Container", prefixes)
    end

    should "return a set of resources stashed in the passed collection" do
      answer = rdf_container(@testResource)
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"})
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Marge"})
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Bart"})
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Lisa"})
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Maggie"})
    end

    should "use a container validator that recognizes container" do
      assert validContainer?(@testResource, @testResource.sparql)
    end

    should "use a container validator that recognizes non container" do
      resource = res_helper.basic_resource("http://Test")
      assert !(validContainer?(resource, resource.sparql))
    end
  end
end