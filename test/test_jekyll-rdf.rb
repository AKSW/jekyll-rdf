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
  
  context "A page confilicting with a rdf-resource page" do
    should "create a hybrid of both pages" do
      s = File.read("#{TestHelper::DEST_DIR}#{TestHelper::BASE_URL}/conflict/index.html")
      expect(s).to include "<h1>This page is a conflict wrapper for the following page:</h1>"
      expect(s).to include "<div>conflict</div>"
    end
  end
end
#test
