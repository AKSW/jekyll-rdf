require 'test_helper'

class TestGeneral < Test::Unit::TestCase
  include RSpec::Matchers
  include RdfTestUtility
  context "Jekyll-Rdf" do
    setup do
      setup_jekyll File.dirname(__FILE__)
    end

    should "create a file which contains http://example.org/instance#resource1" do
      s = File.read(File.join(@source,"_site/index.html")) # read static file
      expect(s).to include 'http://example.org/instance#resource1'
    end

    should "create a file which shows descriptions as property" do
      s = File.read(File.join(@source,"_site/index.html")) # read static file
      expect(s).to include "describes resource1"
    end

    should "create a file for http://outside.org/resource" do
      s = File.read(File.join(@source,"_site/rdfsites/http/outside.org/resource.html")) # read static file
      expect(s).to include "http://outside.org/resource"
      assert true
    end

    should "correctly distinguish between resources supported by the knowledgebase and not supported resources" do
      c = File.read(File.join(@source, "_site/covered.html"))
      expect(c).to include "<div class=\"covered\">http://example.org/instance/coveredResource || true"
      expect(c).to include "<div class=\"uncovered\">http://example.org/instance/uncoveredResource || false"
    end

    should "create a page with a main resource and sub resources" do
      s = File.read(File.join(@source,"_site/index.html")) # read static file
      expect(s).to include "http://example.org/instance"
      expect(s).to include "http://example.org/instance#resource1"
      expect(s).to include "http://example.org/instance#resource2"
    end

    should "support prefixes on non RdfPages too" do
      file = File.read(File.join(@source, "_site/prefixes.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert "<h6>Prefix foaf:Person</h6>".eql?(content[0]), "Headline should be <h6>Prefix foaf:Person</h6>\nIt was: #{content[0]}"
      assert "http://xmlns.com/foaf/0.1/Person".eql?(content[1]), "This line should be >>>http://xmlns.com/foaf/0.1/Person<<< \nIt was :#{content[1]}"
      assert "<h6>Prefix rdf:type</h6>".eql?(content[2]), "Headline should be <h6>Prefix rdf:type</h6>\nIt was: #{content[2]}"
      assert "http://www.w3.org/1999/02/22-rdf-syntax-ns#type".eql?(content[3]), "This line should be >>>http://www.w3.org/1999/02/22-rdf-syntax-ns#type<<< \nIt was :#{content[3]}"
      assert "<h6>Prefix rdfs:Container</h6>".eql?(content[4]), "Headline should be <h6>Prefix rdf:type</h6>\nIt was: #{content[4]}"
      assert "http://www.w3.org/2000/01/rdf-schema#Container".eql?(content[5]), "This line should be >>>http://www.w3.org/2000/01/rdf-schema#Container<<< \nIt was :#{content[5]}"
    end
  end
end
