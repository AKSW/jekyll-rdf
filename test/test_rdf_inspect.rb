require 'test_helper'

class TestRdfResource < Test::Unit::TestCase
  graph = RDF::Graph.load(TestHelper::TEST_OPTIONS['jekyll_rdf']['path'])
  sparql = SPARQL::Client.new(graph)
  context "rdfResource.inspect" do
    setup do
      @resource = Jekyll::Drops::RdfResource.new("http://test.this/resource", sparql)
      @resourceSubs = Jekyll::Drops::RdfResource.new("http://test.this/resource/with/sub/resources", sparql)
      @resourceSubs.subResources = [Jekyll::Drops::RdfResource.new("http://test.this/resource/with/sub/resources1", sparql), Jekyll::Drops::RdfResource.new("http://test.this/resource/with/sub/resources2", sparql), Jekyll::Drops::RdfResource.new("http://test.this/resource/with/sub/resources3", sparql), Jekyll::Drops::RdfResource.new("http://test.this/resource/with/sub/resources4", sparql), Jekyll::Drops::RdfResource.new("http://test.this/resource/with/sub/resources5", sparql), Jekyll::Drops::RdfResource.new("http://test.this/resource/with/sub/resources6", sparql)]
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
      @literal = Jekyll::Drops::RdfLiteral.new("http://a.random/literal")
      @term = Jekyll::Drops::RdfTerm.new("http://a.random/term")
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
      @statement = Jekyll::Drops::RdfStatement.new(RDF::Statement(RDF::URI("http://example.resource/subject"), RDF::Node("http://example.term/predicate"), RDF::Literal("http://example.literal/object")), Object.new)
    end
    should "return the class, the object_id and the term of this object" do
      assert_equal "#<RdfStatement:0x", @statement.inspect[0..16]
      assert_equal "@subject=#<RdfResource:0x", @statement.inspect[32..56]
      assert_equal "@iri=http://example.resource/subject @subResources=[]> @predicate=#<RdfResource:0x", @statement.inspect[72..153]
      assert_equal "@iri=_:http://example.term/predicate @subResources=[]> @object=#<RdfLiteral:0x", @statement.inspect[169..246]
      assert_equal "@term=http://example.literal/object>>", @statement.inspect[262..298]
    end
  end
end