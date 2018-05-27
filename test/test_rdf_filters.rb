require 'test_helper'

class TestRdfFilter < Test::Unit::TestCase
  include Jekyll::JekyllRdf::Filter
  graph = RDF::Graph.load(TestHelper::TEST_OPTIONS['jekyll_rdf']['path'])
  sparql = SPARQL::Client.new(graph)
  res_helper = ResourceHelper.new(sparql)
  context "Filter rdf_property from Jekyll::RdfProperty" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper.sparql = sparql
      prefixes = {"rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdfs" => "http://www.w3.org/2000/01/rdf-schema#", "foaf" => "http://xmlns.com/foaf/0.1/", "fam" => "http://www.ifi.uio.no/INF3580/family#", "sim" => "http://www.ifi.uio.no/INF3580/simpsons#"}
      @testResource = res_helper.resource_with_prefixes_config("http://www.ifi.uio.no/INF3580/simpsons#Homer", prefixes)
      Jekyll::JekyllRdf::Helper::RdfHelper.page = @testResource.page
      Jekyll::JekyllRdf::Helper::RdfHelper.page.data['rdf'] = @testResource
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
      assert(answer.is_a?(Array), "return value is not an array")
      assert(answer.any? {|resource| resource.to_s.eql? "unknown"}, "answerset does not contain 'unknown'")
      assert(answer.any? {|resource| resource.to_s.eql? "unbekannt"}, "answerset does not contain 'unbekannt'")
      assert(answer.any? {|resource| resource.to_s.eql? "unbekannter Job 2"}, "answerset does not contain 'unbekannter Job 2'")
      assert(answer.any? {|resource| resource.to_s.eql? "unknown Job 2"}, "answerset does not contain 'unknown Job 2'")
    end

    should "return a list of properties from specified language" do
      answer = rdf_property(@testResource, "foaf:job", 'en', true)
      assert(answer.is_a?(Array))
      assert(answer.any? {|resource| resource.to_s.eql? "unknown"}, "answerset does not contain 'unknown'")
      assert(!answer.any? {|resource| resource.to_s.eql? "unbekannt"}, "answerset contains 'unbekannt'")
      assert(!answer.any? {|resource| resource.to_s.eql? "unbekannter Job 2"}, "answerset contains 'unbekannter Job 2'")
      assert(answer.any? {|resource| resource.to_s.eql? "unknown Job 2"}, "answerset does not contain 'unknown Job 2'")
    end

    should "return a list of properties from in a config specified language" do
      answer = rdf_property(@testResource, "foaf:job", 'cfg', true)
      assert(answer.is_a?(Array))
      assert(answer.any? {|resource| resource.to_s.eql? "unknown"}, "answerset does not contain 'unknown'")
      assert(!answer.any? {|resource| resource.to_s.eql? "unbekannt"}, "answerset contains 'unbekannt'")
      assert(!answer.any? {|resource| resource.to_s.eql? "unbekannter Job 2"}, "answerset contains 'unbekannter Job 2'")
      assert(answer.any? {|resource| resource.to_s.eql? "unknown Job 2"}, "answerset does not contain 'unknown Job 2'")
    end

    should "be reversable with all specifications" do
      answer = rdf_inverse_property(@testResource, "fam:hasFather", true)
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Bart"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Bart")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Lisa"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Lisa")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Maggie"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Maggie")
    end

    should "be able to substitude nil with the page object" do
      answer = rdf_property(nil, "<http://www.ifi.uio.no/INF3580/family#hasSpouse>")
      assert_equal("http://www.ifi.uio.no/INF3580/simpsons#Marge", answer.to_s)
    end

    should "substitude nil with the page object even in the reverse variant" do
      answer = rdf_inverse_property(nil, "<http://www.ifi.uio.no/INF3580/family#hasSpouse>")
      assert_equal("http://www.ifi.uio.no/INF3580/simpsons#Marge", answer.to_s)
      answer = rdf_inverse_property(nil, "<http://xmlns.com/foaf/0.1/name>")
      assert_equal("http://placeholder.host.plh/placeholder#TPerson", answer.to_s)
    end

    should "accept Strings as first parameter" do
      assert_equal(rdf_property("<http://www.ifi.uio.no/INF3580/simpsons#Homer>", "<http://www.ifi.uio.no/INF3580/family#hasSpouse>").to_s, "http://www.ifi.uio.no/INF3580/simpsons#Marge")
      assert_equal(rdf_property("sim:Homer", "fam:hasSpouse").to_s, "http://www.ifi.uio.no/INF3580/simpsons#Marge")
    end
  end

  context "Filter sparql_query from Jekyll::RdfSparqlQuery" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper.sparql = sparql
      prefixes = {"rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdfs" => "http://www.w3.org/2000/01/rdf-schema#", "foaf" => "http://xmlns.com/foaf/0.1/", "fam" => "http://www.ifi.uio.no/INF3580/family#"}
      @testResource = res_helper.resource_with_prefixes_config("http://www.ifi.uio.no/INF3580/simpsons#Homer", prefixes)
      Jekyll::JekyllRdf::Helper::RdfHelper.page = @testResource.page
      Jekyll::JekyllRdf::Helper::RdfHelper.page.data['rdf'] = @testResource
    end

    should "return an array of solutions to one query" do
      query = "SELECT ?x ?y WHERE{ ?x <http://www.ifi.uio.no/INF3580/family#hasFather> ?y}"
      answer = sparql_query(query)
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://www.ifi.uio.no/INF3580/simpsons#Bart') && (solution['y'].to_s.eql?  'http://www.ifi.uio.no/INF3580/simpsons#Homer')}, "answerset does not contain the pair http://www.ifi.uio.no/INF3580/simpsons#Bart and http://www.ifi.uio.no/INF3580/simpsons#Homer")
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://www.ifi.uio.no/INF3580/simpsons#Lisa') && (solution['y'].to_s.eql?  'http://www.ifi.uio.no/INF3580/simpsons#Homer')}, "answerset does not contain the pair http://www.ifi.uio.no/INF3580/simpsons#Lisa and http://www.ifi.uio.no/INF3580/simpsons#Homer")
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://www.ifi.uio.no/INF3580/simpsons#Maggie') && (solution['y'].to_s.eql?  'http://www.ifi.uio.no/INF3580/simpsons#Homer')}, "answerset does not contain the pair http://www.ifi.uio.no/INF3580/simpsons#Maggie and http://www.ifi.uio.no/INF3580/simpsons#Homer")
    end

    should "return an array of solutions to one query with prefixes" do
      query = "SELECT ?x ?y WHERE{ ?x fam:hasFather ?y}"
      answer = sparql_query(query)
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://www.ifi.uio.no/INF3580/simpsons#Bart') && (solution['y'].to_s.eql?  'http://www.ifi.uio.no/INF3580/simpsons#Homer')}, "answerset does not contain the pair http://www.ifi.uio.no/INF3580/simpsons#Bart and http://www.ifi.uio.no/INF3580/simpsons#Homer")
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://www.ifi.uio.no/INF3580/simpsons#Lisa') && (solution['y'].to_s.eql?  'http://www.ifi.uio.no/INF3580/simpsons#Homer')}, "answerset does not contain the pair http://www.ifi.uio.no/INF3580/simpsons#Lisa and http://www.ifi.uio.no/INF3580/simpsons#Homer")
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://www.ifi.uio.no/INF3580/simpsons#Maggie') && (solution['y'].to_s.eql?  'http://www.ifi.uio.no/INF3580/simpsons#Homer')}, "answerset does not contain the pair http://www.ifi.uio.no/INF3580/simpsons#Maggie and http://www.ifi.uio.no/INF3580/simpsons#Homer")
    end

    should "properly substitude ?resourceUri with the given resource" do
      query = "SELECT ?y WHERE{ ?resourceUri foaf:age ?y}"
      answer = sparql_query(@testResource, query)
      assert(answer.any? {|solution| solution['y'].to_s.eql?  '36'}, "answer should return the age of Homer Simpson (36)")
    end

    should "properly substitude ?resourceUri_#num with a given set of resource" do
      query = "SELECT ?x WHERE {?resourceUri_0 ?x ?resourceUri_1}"
      answer = sparql_query([Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI.new("http://www.ifi.uio.no/INF3580/simpsons#Homer")), Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI.new("http://www.ifi.uio.no/INF3580/simpsons#Marge"))], query)
      assert(answer.any? {|solution| solution['x'].to_s.eql? 'http://www.ifi.uio.no/INF3580/family#hasSpouse'}, "answerset should contain http://www.ifi.uio.no/INF3580/family#hasSpouse.\n    Returned answers:\n     #{answer.inspect}")
      query = "SELECT ?x WHERE {?resourceUri_0 ?x ?resourceUri_1}"
      answer = sparql_query(["<http://www.ifi.uio.no/INF3580/simpsons#Homer>", "<http://www.ifi.uio.no/INF3580/simpsons#Marge>"], query)
      assert(answer.any? {|solution| solution['x'].to_s.eql? 'http://www.ifi.uio.no/INF3580/family#hasSpouse'}, "answerset should contain http://www.ifi.uio.no/INF3580/family#hasSpouse.\n    Returned answers:\n     #{answer.inspect}")
    end

    # These 3 tests are prune to errors if rdf_resource changes to use sparql in its setup process
    should "log a SPARQL::Client::ClientError Exception" do
      TestHelper::setErrOutput
      Jekyll::JekyllRdf::Helper::RdfHelper::sparql = res_helper.faulty_sparql_client(:ClientError)
      query = "SELECT ?x ?y WHERE{ ?x <http://www.ifi.uio.no/INF3580/family#hasFather> ?y}"
      sparql_query(query)
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /client error experienced:.*/)} , "missing error message: client error experienced: ****"
      TestHelper::resetErrOutput
    end

    should "log a SPARQL::MalformedQuery Exception" do
      TestHelper::setErrOutput
      Jekyll::JekyllRdf::Helper::RdfHelper::sparql = res_helper.faulty_sparql_client(:MalformedQuery)
      query = "SELECT ?x ?y WHERE{ ?x <http://www.ifi.uio.no/INF3580/family#hasFather> ?y}"
      sparql_query(query)
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /client error experienced:.*/)}, "missing error message: client error experienced: ****"
      TestHelper::resetErrOutput
    end

    should "log a basic Exception if an unknown exception occurs" do
      TestHelper::setErrOutput
      Jekyll::JekyllRdf::Helper::RdfHelper::sparql = res_helper.faulty_sparql_client(:Exception)
      query = "SELECT ?x ?y WHERE{ ?x <http://www.ifi.uio.no/INF3580/family#hasFather> ?y}"
      sparql_query(query)
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /client error experienced:.*/)}, "missing error message: client error experienced: ****"
      TestHelper::resetErrOutput
    end

    should "accept Strings as parameters for resourceUri" do
      query = "SELECT ?y WHERE{ ?resourceUri foaf:age ?y}"
      answer = sparql_query("<http://www.ifi.uio.no/INF3580/simpsons#Homer>", query)
      assert(answer.any? {|solution| solution['y'].to_s.eql?  '36'}, "answer should return the age of Homer Simpson (36)")
    end
  end

  context "rdf_resolve_prefix from Jekyll::RdfPrefixResolver" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper.sparql = sparql
      prefixes = {"rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdfs" => "http://www.w3.org/2000/01/rdf-schema#", "foaf" => "http://xmlns.com/foaf/0.1/", "fam" => "http://www.ifi.uio.no/INF3580/family#"}
      @testResource = res_helper.resource_with_prefixes_config("http://www.ifi.uio.no/INF3580/simpsons#Homer", prefixes)
      Jekyll::JekyllRdf::Helper::RdfHelper.page = @testResource.page
      Jekyll::JekyllRdf::Helper::RdfHelper.page.data['rdf'] = @testResource
    end

    should "resolve the prefix foaf to its full length" do
      answer = rdf_resolve_prefix('foaf:name')
      assert_equal(answer, "<http://xmlns.com/foaf/0.1/name>")
    end

    should "return the uri of any correctly marked uri" do
      answer = rdf_resolve_prefix('<http://xmlns.com/foaf/0.1/name>')
      assert_equal(answer, '<http://xmlns.com/foaf/0.1/name>')
    end

    should "raise an UnMarkedUri exception if there is a full uri instead of a prefix" do
      assert_raise UnMarkedUri do
        rdf_resolve_prefix('http://xmlns.com/foaf/0.1/name')
      end
    end

    should "raise a NoPrefixMapped exception if no fitting prefix is found" do
      assert_raise NoPrefixMapped do
        rdf_resolve_prefix('foae:name')
      end
    end

    should "raise a NoPrefixesDefined exception if no prefixes are found" do
      resource = res_helper.basic_resource("test")
      Jekyll::JekyllRdf::Helper::RdfHelper::page.data["rdf_prefixes"] = nil
      assert_raise NoPrefixesDefined do
        rdf_resolve_prefix('foae:name')
      end
    end
  end

  context "rdf_resolve_prefix on global prefixes from Jekyll::RdfPrefixResolver" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper::prefixes = File.join(Dir.pwd, "test/source/rdf-data/simpsons.pref")
      Jekyll::JekyllRdf::Helper::RdfHelper::page = {}
    end

    should "resolve the prefix foaf to its full length" do
      answer = rdf_resolve_prefix('foaf:name')
      assert_equal(answer, "<http://xmlns.com/foaf/0.1/name>")
    end
  end

  context "Filter rdf_collection from Jekyll::RdfCollection" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper.sparql = sparql
      prefixes = {"rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdfs" => "http://www.w3.org/2000/01/rdf-schema#", "foaf" => "http://xmlns.com/foaf/0.1/", "fam" => "http://www.ifi.uio.no/INF3580/family#", "simc" => "http://www.ifi.uio.no/INF3580/simpson-collection#"}
      @testResource = res_helper.resource_with_prefixes_config("http://www.ifi.uio.no/INF3580/simpson-collection#Collection", prefixes)
      Jekyll::JekyllRdf::Helper::RdfHelper.page = @testResource.page
      Jekyll::JekyllRdf::Helper::RdfHelper.page.data['rdf'] = @testResource
    end

    should "return a set of resources stashed in the passed collection" do
      answer = rdf_collection(@testResource)
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Homer")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Marge"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Marge")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Bart"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Bart")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Lisa"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Lisa")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Maggie"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Maggie")
    end

    should "substitude nil with the page resource object" do
      answer = rdf_collection(nil)
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Homer")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Marge"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Marge")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Bart"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Bart")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Lisa"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Lisa")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Maggie"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Maggie")
    end

    should "accept a String as first parameter" do
      answer = rdf_collection("<http://www.ifi.uio.no/INF3580/simpson-collection#Collection>")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Homer")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Marge"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Marge")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Bart"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Bart")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Lisa"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Lisa")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Maggie"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Maggie")
    end
  end

  context "Filter rdf_collection with argument from Jekyll::RdfCollection and a predicate as shortcut" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper.sparql = sparql
      prefixes = {"rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdfs" => "http://www.w3.org/2000/01/rdf-schema#", "foaf" => "http://xmlns.com/foaf/0.1/", "fam" => "http://www.ifi.uio.no/INF3580/family#", "simc" => "http://www.ifi.uio.no/INF3580/simpson-collection#"}
      @testResource = res_helper.resource_with_prefixes_config("http://pcai042.informatik.uni-leipzig.de/~dtp16#TestEntity", prefixes)
      Jekyll::JekyllRdf::Helper::RdfHelper.page = @testResource.page
      Jekyll::JekyllRdf::Helper::RdfHelper.page.data['rdf'] = @testResource
    end

    should "return a set of resources stashed in the passed collection" do
      answer = rdf_collection(nil, "<http://pcai042.informatik.uni-leipzig.de/~dtp16#hasList>")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Homer")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Marge"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Marge")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Lisa"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Lisa")
    end
  end

  context "Filter rdf_container from Jekyll::RdfContainer" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper.sparql = sparql
      prefixes = {"rdf" => "http://www.w3.org/1999/02/22-rdf-syntax-ns#", "rdfs" => "http://www.w3.org/2000/01/rdf-schema#", "foaf" => "http://xmlns.com/foaf/0.1/", "fam" => "http://www.ifi.uio.no/INF3580/family#", "simcon" => "http://www.ifi.uio.no/INF3580/simpson-container#"}
      @testSeq = res_helper.resource_with_prefixes_config("http://www.ifi.uio.no/INF3580/simpson-container#Seq", prefixes)
      @testContainer = res_helper.resource_with_prefixes_config("http://www.ifi.uio.no/INF3580/simpson-container#Container", prefixes)
      @testCustomContainer = res_helper.resource_with_prefixes_config("http://www.ifi.uio.no/INF3580/simpson-container#CustomContainer", prefixes)
      Jekyll::JekyllRdf::Helper::RdfHelper.page = @testSeq.page
      Jekyll::JekyllRdf::Helper::RdfHelper.page.data['rdf'] = @testSeq
    end

    should "return a set of resources stashed in the passed sequence container" do
      answer = rdf_container(@testSeq)
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Homer")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Marge"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Marge")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Bart"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Bart")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Lisa"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Lisa")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Maggie"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Maggie")
    end

    should "return a set of resources stashed in the passed container" do
      answer = rdf_container(@testContainer)
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Homer")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Marge"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Marge")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Bart"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Bart")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Lisa"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Lisa")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Maggie"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Maggie")
    end

    should "return a set of resources stashed in the passed custom collection" do
      answer = rdf_container(@testCustomContainer)
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Homer")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Marge"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Marge")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Bart"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Bart")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Lisa"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Lisa")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Maggie"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Maggie")
    end

    should "use a container validator that recognizes container" do
      assert valid_container?(@testSeq.term.to_ntriples), "validContainer? returned false"
    end

    should "use a container validator that recognizes non container" do
      resource = res_helper.basic_resource("http://Test")
      assert !(valid_container?(resource.term.to_ntriples)), "validContainer? returned true"
    end

    should "substitude nil with the page resource object" do
      answer = rdf_container(nil)
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Homer")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Marge"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Marge")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Bart"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Bart")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Lisa"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Lisa")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Maggie"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Maggie")
    end

    should "accept a string as first parameter" do
      answer = rdf_container("<http://www.ifi.uio.no/INF3580/simpson-container#Seq>")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Homer")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Marge"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Marge")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Bart"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Bart")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Lisa"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Lisa")
      assert(answer.any? {|resource| resource.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Maggie"}, "answerset does not contain http://www.ifi.uio.no/INF3580/simpsons#Maggie")
    end
  end

  context "Filter rdf_get from Jekyll::RdfGet" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper::sparql = sparql
      Jekyll::JekyllRdf::Helper::RdfHelper::site = Jekyll::Site.new(Jekyll.configuration(TestHelper::TEST_OPTIONS))
      prefixes = {"base" => "http://www.ifi.uio.no/INF3580/"}
      Jekyll::JekyllRdf::Helper::RdfHelper::page = res_helper.resource_with_prefixes_config("http://example.com", prefixes).page
    end

    should "return the resource base:main" do
      test_resource =  rdf_get("base:main")
      assert_equal "http://www.ifi.uio.no/INF3580/main", test_resource.iri
      assert (test_resource.site.eql? Jekyll::JekyllRdf::Helper::RdfHelper::site), "The resource should contain the same site as Jekyll::JekyllRdf::Helper::RdfHelper"
      assert (test_resource.page.eql? Jekyll::JekyllRdf::Helper::RdfHelper::page), "The resource should contain the same page as Jekyll::JekyllRdf::Helper::RdfHelper: #{Jekyll::JekyllRdf::Helper::RdfHelper::page.inspect} <=> #{test_resource.page}"
    end

    should "substitude nil with page resource" do
      Jekyll::JekyllRdf::Helper::RdfHelper::page.data["rdf"] = res_helper.basic_resource("http://www.ifi.uio.no/INF3580/main")
      test_resource =  rdf_get(nil)
      assert_equal "http://www.ifi.uio.no/INF3580/main", test_resource.iri
    end

    should "return the input if the input is a resource" do
      resource = Jekyll::JekyllRdf::Drops::RdfResource.new("http://example.com", nil, nil, true)
      assert_equal resource, rdf_get(resource)
    end

    should "return nothing if the input is a resource not rooted in the knowledgebase" do
      resource = Jekyll::JekyllRdf::Drops::RdfResource.new("Not/from/this/knowledge/base")
      assert rdf_get(resource).nil?, "rdf_get shouldn't have returned anything for resource Not/from/this/knowledge/base"
    end

    should "return the resource of the input page hash if a hash is supplied" do
      Jekyll::JekyllRdf::Helper::RdfHelper::page.data["rdf"] = res_helper.basic_resource("http://www.ifi.uio.no/INF3580/main")
      test_resource = rdf_get({"template" => "", "url" => "", "path" => "", "rdf" => res_helper.basic_resource("http://www.ifi.uio.no/INF3580/main")})
      assert_equal "http://www.ifi.uio.no/INF3580/main", test_resource.iri
    end
  end
end
