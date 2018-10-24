require 'test_helper'

class TestRdfFilter < Test::Unit::TestCase
  include Jekyll::JekyllRdf::Filter
  graph = RDF::Graph.load(File.join(File.dirname(__FILE__), "_data/knowledge-base.ttl"))
  sparql = SPARQL::Client.new(graph)
  prefix_path = File.join(File.dirname(__FILE__), "_data/Prefixes.pref")
  res_helper = ResourceHelper.new(sparql)

  class PseudoPage
    def resource= res
      @resource = res
    end

    def data
      return {'rdf' => @resource} unless @resource.nil?
      return {}
    end
  end

  class PseudoSite
    def config
      {'jekyll_rdf' => {'language' => 'en'}}
    end
  end

  context "Filter rdf_property from Jekyll::RdfProperty" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper.sparql = sparql
      Jekyll::JekyllRdf::Helper::RdfHelper.page = PseudoPage.new()  # do that to make rdf_general_helper use general Prefixes
      Jekyll::JekyllRdf::Helper::RdfHelper.prefixes = prefix_path
    end

    should "return the correct URI" do
      answer = rdf_property(Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/resource")), "<http://example.org/instance/predicate>")
      assert_equal(answer.to_s, "http://example.org/instance/object")
    end

    should "return the correct URI when prefixes are used" do
      answer = rdf_property(Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/resource")), "eg:predicate")
      assert_equal(answer.to_s, "http://example.org/instance/object")
    end

    should "return a list of properties when 'list' parameter is set" do
      answer = rdf_property(Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/resource")), "eg:prelist", nil, true)
      assert(answer.is_a?(Array), "return value is not an array")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/object1"}, "answerset does not contain 'http://example.org/instance/object1'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/object2"}, "answerset does not contain 'http://example.org/instance/object2'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/object3"}, "answerset does not contain 'http://example.org/instance/object3'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/object4"}, "answerset does not contain 'http://example.org/instance/object4'")
    end

    should "return a list of properties from specified language" do
      answer = rdf_property(Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/resource")), "eg:literals", 'en', true)
      assert(answer.is_a?(Array), "the answer was not an array")
      assert(answer.any? {|resource| resource.to_s.eql? "unknown"}, "answerset does not contain 'unknown'")
      assert(!answer.any? {|resource| resource.to_s.eql? "unbekannt"}, "answerset contains 'unbekannt'")
      assert(!answer.any? {|resource| resource.to_s.eql? "unbekannt 2"}, "answerset contains 'unbekannt 2'")
      assert(answer.any? {|resource| resource.to_s.eql? "unknown 2"}, "answerset does not contain 'unknown 2'")
    end

    should "return a list of properties from in a config specified language" do
      Jekyll::JekyllRdf::Helper::RdfHelper.site = PseudoSite.new()
      answer = rdf_property(Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/resource")), "eg:literals", 'cfg', true)
      assert(answer.is_a?(Array), "the answer was not an array")
      assert(answer.any? {|resource| resource.to_s.eql? "unknown"}, "answerset does not contain 'unknown'")
      assert(!answer.any? {|resource| resource.to_s.eql? "unbekannt"}, "answerset contains 'unbekannt'")
      assert(!answer.any? {|resource| resource.to_s.eql? "unbekannt 2"}, "answerset contains 'unbekannt 2'")
      assert(answer.any? {|resource| resource.to_s.eql? "unknown 2"}, "answerset does not contain 'unknown 2'")
    end

    should "be reversable with all specifications" do
      answer = rdf_inverse_property(Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/object")), "eg:predicate", true)
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/resource"},  "answerset does not contain http://example.org/instance/resource")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/resource1"}, "answerset does not contain http://example.org/instance/resource1")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/resource2"}, "answerset does not contain http://example.org/instance/resource2")
    end

    should "be able to substitude nil with the page object" do
      page_resource = Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/resource"))
      Jekyll::JekyllRdf::Helper::RdfHelper.page = PseudoPage.new
      Jekyll::JekyllRdf::Helper::RdfHelper.page.resource = page_resource
      answer = rdf_property(nil, "<http://example.org/instance/predicate>")
      assert_equal("http://example.org/instance/object", answer.to_s)
    end

    should "substitude nil with the page object even in the reverse variant" do
      page_resource = Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/object1"))
      Jekyll::JekyllRdf::Helper::RdfHelper.page = PseudoPage.new
      Jekyll::JekyllRdf::Helper::RdfHelper.page.resource = page_resource
      answer = rdf_inverse_property(nil, "<http://example.org/instance/prelist>")
      assert_equal("http://example.org/instance/resource", answer.to_s)
    end

    should "accept Strings as first parameter" do
      assert_equal(rdf_property("<http://example.org/instance/resource>", "<http://example.org/instance/predicate>").to_s, "http://example.org/instance/object")
    end
  end

  context "Filter sparql_query from Jekyll::RdfSparqlQuery" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper.sparql = sparql
      Jekyll::JekyllRdf::Helper::RdfHelper.page = PseudoPage.new()  # do that to make rdf_general_helper use general Prefixes
      Jekyll::JekyllRdf::Helper::RdfHelper.prefixes = prefix_path
    end

    should "return an array of solutions to one query" do
      query = "SELECT ?x ?y WHERE{ ?x <http://example.org/instance/predicate> ?y}"
      answer = sparql_query(query)
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://example.org/instance/resource') && (solution['y'].to_s.eql? 'http://example.org/instance/object')}, "answerset does not contain the pair 'http://example.org/instance/resource' and 'http://example.org/instance/object'")
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://example.org/instance/resource1') && (solution['y'].to_s.eql?  'http://example.org/instance/object')}, "answerset does not contain the pair 'http://example.org/instance/resource1' and 'http://example.org/instance/object'")
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://example.org/instance/resource2') && (solution['y'].to_s.eql?  'http://example.org/instance/object')}, "answerset does not contain the pair 'http://example.org/instance/resource2' and 'http://example.org/instance/object'")
    end

    should "return an array of solutions to one query with prefixes" do
      query = "SELECT ?x ?y WHERE{ ?x eg:predicate ?y}"
      answer = sparql_query(query)
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://example.org/instance/resource') && (solution['y'].to_s.eql? 'http://example.org/instance/object')}, "answerset does not contain the pair 'http://example.org/instance/resource' and 'http://example.org/instance/object'")
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://example.org/instance/resource1') && (solution['y'].to_s.eql?  'http://example.org/instance/object')}, "answerset does not contain the pair 'http://example.org/instance/resource1' and 'http://example.org/instance/object'")
      assert(answer.any? {|solution| (solution['x'].to_s.eql? 'http://example.org/instance/resource2') && (solution['y'].to_s.eql?  'http://example.org/instance/object')}, "answerset does not contain the pair 'http://example.org/instance/resource2' and 'http://example.org/instance/object'")
    end

    should "properly substitude ?resourceUri with the given resource" do
      query = "SELECT ?y WHERE{ ?resourceUri eg:predicate ?y}"
      answer = sparql_query(Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/resource")), query)
      assert(answer.any? {|solution| solution['y'].to_s.eql?  'http://example.org/instance/object'}, "answer should return 'http://example.org/instance/object'")
    end

    should "properly substitude ?resourceUri_#num with a given set of resource" do
      query = "SELECT ?x WHERE {?resourceUri_0 ?x ?resourceUri_1}"
      answer = sparql_query([Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI.new("http://example.org/instance/resource")), Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI.new("http://example.org/instance/object"))], query)
      assert(answer.any? {|solution| solution['x'].to_s.eql? 'http://example.org/instance/predicate'}, "answerset should contain http://example.org/instance/predicate.\n    Returned answers:\n     #{answer.inspect}")
    end

    # These 3 tests are prune to errors if rdf_resource changes to use sparql in its setup process
    should "log a SPARQL::Client::ClientError Exception" do
      TestHelper::setErrOutput
      Jekyll::JekyllRdf::Helper::RdfHelper::sparql = res_helper.faulty_sparql_client(:ClientError)
      query = "SELECT ?x ?y WHERE{ ?x <http://example.org/instance/predicate> ?y}"
      assert_raise do
        sparql_query(query)
      end
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /client error experienced:.*/)} , "missing error message: client error experienced: ****"
      TestHelper::resetErrOutput
    end

    should "log a SPARQL::MalformedQuery Exception" do
      TestHelper::setErrOutput
      Jekyll::JekyllRdf::Helper::RdfHelper::sparql = res_helper.faulty_sparql_client(:MalformedQuery)
      query = "SELECT ?x ?y WHERE{ ?x <http://example.org/instance/predicate> ?y}"
      assert_raise do
        sparql_query(query)
      end
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /client error experienced:.*/)}, "missing error message: client error experienced: ****"
      TestHelper::resetErrOutput
    end

    should "log a basic Exception if an unknown exception occurs" do
      TestHelper::setErrOutput
      Jekyll::JekyllRdf::Helper::RdfHelper::sparql = res_helper.faulty_sparql_client(:Exception)
      query = "SELECT ?x ?y WHERE{ ?x <http://example.org/instance/predicate> ?y}"
      assert_raise do
        sparql_query(query)
      end
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /client error experienced:.*/)}, "missing error message: client error experienced: ****"
      TestHelper::resetErrOutput
    end

    should "accept Strings as parameters for resourceUri" do
      query = "SELECT ?y WHERE{ ?resourceUri eg:predicate ?y}"
      answer = sparql_query("<http://example.org/instance/resource>", query)
      assert(answer.any? {|solution| solution['y'].to_s.eql?  'http://example.org/instance/object'}, "answer should return <http://example.org/instance/object>")
    end
  end

  context "rdf_resolve_prefix from Jekyll::RdfPrefixResolver" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper.sparql = sparql
      Jekyll::JekyllRdf::Helper::RdfHelper.page = PseudoPage.new()  # do that to make rdf_general_helper use general Prefixes
      Jekyll::JekyllRdf::Helper::RdfHelper.prefixes = prefix_path
    end

    should "resolve the prefix eg to its full length" do
      answer = rdf_resolve_prefix('eg:resource')
      assert_equal(answer, "<http://example.org/instance/resource>")
    end

    should "return the uri of any correctly marked uri" do
      answer = rdf_resolve_prefix('<http://example.org/instance/resource>')
      assert_equal(answer, '<http://example.org/instance/resource>')
    end

    should "raise an UnMarkedUri exception if there is a full uri instead of a prefix" do
      assert_raise UnMarkedUri do
        rdf_resolve_prefix('http://example.org/instance/resource')
      end
    end

    should "raise a NoPrefixMapped exception if no fitting prefix is found" do
      assert_raise NoPrefixMapped do
        rdf_resolve_prefix('prim:resource')
      end
    end

    should "raise a NoPrefixesDefined exception if no prefixes are found" do
      Jekyll::JekyllRdf::Helper::RdfHelper::prefixes["rdf_prefixes"] = nil
      assert_raise NoPrefixesDefined do
        rdf_resolve_prefix('foae:name')
      end
    end
  end

  context "Filter rdf_collection from Jekyll::RdfCollection" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper.sparql = sparql
      Jekyll::JekyllRdf::Helper::RdfHelper.page = PseudoPage.new()  # do that to make rdf_general_helper use general Prefixes
      Jekyll::JekyllRdf::Helper::RdfHelper.prefixes = prefix_path
    end

    should "return a set of resources stashed in the passed collection" do
      answer = rdf_collection(Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/collection")))
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem1"}, "answerset does not contain 'http://example.org/instance/colItem1'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem2"}, "answerset does not contain 'http://example.org/instance/colItem2'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem3"}, "answerset does not contain 'http://example.org/instance/colItem3'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem4"}, "answerset does not contain 'http://example.org/instance/colItem4'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem5"}, "answerset does not contain 'http://example.org/instance/colItem5'")
    end

    should "substitude nil with the page resource object" do
      Jekyll::JekyllRdf::Helper::RdfHelper.page = PseudoPage.new
      Jekyll::JekyllRdf::Helper::RdfHelper.page.resource = Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/collection"))
      answer = rdf_collection(nil)
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem1"}, "answerset does not contain 'http://example.org/instance/colItem1'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem2"}, "answerset does not contain 'http://example.org/instance/colItem2'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem3"}, "answerset does not contain 'http://example.org/instance/colItem3'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem4"}, "answerset does not contain 'http://example.org/instance/colItem4'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem5"}, "answerset does not contain 'http://example.org/instance/colItem5'")
    end

    should "accept a String as first parameter" do
      answer = rdf_collection("<http://example.org/instance/collection>")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem1"}, "answerset does not contain 'http://example.org/instance/colItem1'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem2"}, "answerset does not contain 'http://example.org/instance/colItem2'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem3"}, "answerset does not contain 'http://example.org/instance/colItem3'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem4"}, "answerset does not contain 'http://example.org/instance/colItem4'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem5"}, "answerset does not contain 'http://example.org/instance/colItem5'")
    end

    should "accept a resource predicate tupel as pointer (shortcut) to a collection" do
      answer = rdf_collection("<http://example.org/instance/colPointer>", "<http://example.org/instance/collect>")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem1"}, "answerset does not contain 'http://example.org/instance/colItem1'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem2"}, "answerset does not contain 'http://example.org/instance/colItem2'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem3"}, "answerset does not contain 'http://example.org/instance/colItem3'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem4"}, "answerset does not contain 'http://example.org/instance/colItem4'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem5"}, "answerset does not contain 'http://example.org/instance/colItem5'")
    end
  end

  context "Filter rdf_container from Jekyll::RdfContainer" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper.sparql = sparql
      Jekyll::JekyllRdf::Helper::RdfHelper.page = PseudoPage.new()  # do that to make rdf_general_helper use general Prefixes
      Jekyll::JekyllRdf::Helper::RdfHelper.prefixes = prefix_path
    end

    should "return a set of resources stashed in the passed sequence container" do
      answer = rdf_container(Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/Seq")))
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem1"}, "answerset does not contain 'http://example.org/instance/conItem1'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem2"}, "answerset does not contain 'http://example.org/instance/conItem2'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem3"}, "answerset does not contain 'http://example.org/instance/conItem3'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem4"}, "answerset does not contain 'http://example.org/instance/conItem4'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem5"}, "answerset does not contain 'http://example.org/instance/conItem5'")
    end

    should "return a set of resources stashed in the passed container" do
      answer = rdf_container(Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/Container")))
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem1"}, "answerset does not contain 'http://example.org/instance/conItem1'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem2"}, "answerset does not contain 'http://example.org/instance/conItem2'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem3"}, "answerset does not contain 'http://example.org/instance/conItem3'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem4"}, "answerset does not contain 'http://example.org/instance/conItem4'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem5"}, "answerset does not contain 'http://example.org/instance/conItem5'")
    end

    should "return a set of resources stashed in the passed custom collection" do
      answer = rdf_container(Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/CustomContainer")))
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem1"}, "answerset does not contain 'http://example.org/instance/conItem1'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem2"}, "answerset does not contain 'http://example.org/instance/conItem2'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem3"}, "answerset does not contain 'http://example.org/instance/conItem3'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem4"}, "answerset does not contain 'http://example.org/instance/conItem4'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem5"}, "answerset does not contain 'http://example.org/instance/conItem5'")
    end

    should "substitude nil with the page resource object" do
      Jekyll::JekyllRdf::Helper::RdfHelper.page = PseudoPage.new
      Jekyll::JekyllRdf::Helper::RdfHelper.page.resource = Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/Seq"))
      answer = rdf_container(nil)
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem1"}, "answerset does not contain 'http://example.org/instance/conItem1'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem2"}, "answerset does not contain 'http://example.org/instance/conItem2'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem3"}, "answerset does not contain 'http://example.org/instance/conItem3'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem4"}, "answerset does not contain 'http://example.org/instance/conItem4'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem5"}, "answerset does not contain 'http://example.org/instance/conItem5'")
    end

    should "accept a string as first parameter" do
      answer = rdf_container("<http://example.org/instance/Seq>")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem1"}, "answerset does not contain 'http://example.org/instance/conItem1'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem2"}, "answerset does not contain 'http://example.org/instance/conItem2'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem3"}, "answerset does not contain 'http://example.org/instance/conItem3'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem4"}, "answerset does not contain 'http://example.org/instance/conItem4'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem5"}, "answerset does not contain 'http://example.org/instance/conItem5'")
    end
  end

  context "Filter rdf_get from Jekyll::RdfGet" do
    setup do
      Jekyll::JekyllRdf::Helper::RdfHelper.sparql = sparql
      Jekyll::JekyllRdf::Helper::RdfHelper.page = PseudoPage.new()  # do that to make rdf_general_helper use general Prefixes
      Jekyll::JekyllRdf::Helper::RdfHelper.prefixes = prefix_path
    end

    should "return the resource eg:resource" do
      Jekyll::JekyllRdf::Helper::RdfHelper::site = Jekyll::Site.new(Jekyll.configuration({}))
      test_resource =  rdf_get("eg:resource")
      assert_equal "http://example.org/instance/resource", test_resource.iri
      assert (test_resource.site.eql? Jekyll::JekyllRdf::Helper::RdfHelper::site), "The resource should contain the same site as Jekyll::JekyllRdf::Helper::RdfHelper"
      #only works for real pages
      #assert (test_resource.page.eql? Jekyll::JekyllRdf::Helper::RdfHelper::page), "The resource should contain the same page as Jekyll::JekyllRdf::Helper::RdfHelper: #{Jekyll::JekyllRdf::Helper::RdfHelper::page.inspect} <=> #{test_resource.page}"
    end

    should "substitude nil with page resource" do
      Jekyll::JekyllRdf::Helper::RdfHelper.page = PseudoPage.new
      Jekyll::JekyllRdf::Helper::RdfHelper.page.resource = Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/resource"))
      test_resource =  rdf_get(nil)
      assert_equal "http://example.org/instance/resource", test_resource.iri
    end

    should "return the input if the input is a resource" do
      resource = Jekyll::JekyllRdf::Drops::RdfResource.new("http://example.org/instance/resource", nil, nil, true)
      assert_equal resource, rdf_get(resource)
    end

    should "still return a resource if the input is a resource not rooted in the knowledgebase" do
      resource = Jekyll::JekyllRdf::Drops::RdfResource.new("Not/from/this/knowledge/base")
      assert !rdf_get(resource).nil?, "rdf_get should have returned the resource Not/from/this/knowledge/base"
    end

    should "return the resource of the input page hash if a hash is supplied" do
      Jekyll::JekyllRdf::Helper::RdfHelper.page = PseudoPage.new
      Jekyll::JekyllRdf::Helper::RdfHelper.page.resource = Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/resource"))
      test_resource = rdf_get({"template" => "", "url" => "", "path" => "", "rdf" => Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI("http://example.org/instance/resource"))})
      assert_equal "http://example.org/instance/resource", test_resource.iri
    end
  end
end
