require 'test_helper'

class TestJekyllRdf < Test::Unit::TestCase
  include RSpec::Matchers
  config = Jekyll.configuration(TestHelper::TEST_OPTIONS)
  site = Jekyll::Site.new(config)
  site.process
  simpson_page = site.pages.find{|p|
    p.name == "simpsons.html".gsub(TestHelper::BASE_URL, '')
  }
  context "Generating a site with RDF data" do
    should "create a file which mentions 'Lisa Simpson'" do
      s = File.read("#{TestHelper::DEST_DIR}#{TestHelper::BASE_URL}/simpsons.html") # read static file
      expect(s).to include 'http://www.ifi.uio.no/INF3580/simpsons#Lisa'
    end

    should "create a file which lists through rdf_property Homers jobs" do
      s = File.read("#{TestHelper::DEST_DIR}#{TestHelper::BASE_URL}/simpsons.html") # read static file
      expect(s).to include "unknown Job 2"
    end

    should "create a file for http://pcai042.informatik.uni-leipzig.de/~dtp16" do
      s = File.read("#{TestHelper::DEST_DIR}#{TestHelper::BASE_URL}/rdfsites/http/pcai042.informatik.uni-leipzig.de/~dtp16.html")
      expect(s).to include "http://pcai042.informatik.uni-leipzig.de/~dtp16"
      assert true
    end
  end

  context "A page generate from RDF data" do
    should "have rdf data" do
      assert_not_nil(simpson_page.data['rdf'])
    end

    should "have subResources" do
      assert simpson_page.data["sub_rdf"].any? {|sub| sub.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Abraham"}, "The simpsons page should have http://www.ifi.uio.no/INF3580/simpsons#Abraham as subresource"
      assert simpson_page.data["sub_rdf"].any? {|sub| sub.to_s.eql? "http://www.ifi.uio.no/INF3580/simpsons#Homer"}, "The simpsons page should have http://www.ifi.uio.no/INF3580/simpsons#Homer as subresource"
    end
  end

  context "Jekyll-Rdf" do
    should "correctly distinguish between resources supported by the knowledgebase and not supported resources" do
      c = File.read("#{TestHelper::DEST_DIR}#{TestHelper::BASE_URL}/rdfsites/http/example.org/super.html")
      u = File.read("#{TestHelper::DEST_DIR}#{TestHelper::BASE_URL}/rdfsites/http/example.org/uncovered.html")
      expect(u).to include "Resource covered?: false"
      expect(c).to include "Resource covered?: true"
    end
  end

  context "Prefixes" do
    should "work on non Rdf Pages too" do
      file = File.read("#{TestHelper::DEST_DIR}/INF3580/ex/prefixes/prefixes/index.html")
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
#test
