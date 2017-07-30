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
      s = File.read("#{TestHelper::DEST_DIR}/INF3580/rdfsites/http/pcai042.informatik.uni-leipzig.de/~dtp16/#/TestPersonMagrid.html")
      expect(s).to include "http://pcai042.informatik.uni-leipzig.de/~dtp16/#TestPersonMagrid"
      assert Jekyll.logger.messages.any? {|message| message.strip.eql? "classMapped: http://pcai042.informatik.uni-leipzig.de/~dtp16/#MagridsSpecialClass : http://pcai042.informatik.uni-leipzig.de/~dtp16/#TestPersonMagrid : person.html"}, "missing error message:\n    classMapped: http://pcai042.informatik.uni-leipzig.de/~dtp16/#MagridsSpecialClass : http://pcai042.informatik.uni-leipzig.de/~dtp16/#TestPersonMagrid : person.html"
      assert Jekyll.logger.messages.any? {|message| message.strip.eql? "Warning: multiple possible templates for http://pcai042.informatik.uni-leipzig.de/~dtp16/#TestPersonMagrid: person.html"}, "missing error message:\n    Warning: multiple possible templates for http://pcai042.informatik.uni-leipzig.de/~dtp16/#TestPersonMagrid: person.html"
    end
  end

  context "A page generate from RDF data" do
    should "have rdf data" do
      assert_not_nil(simpson_page.data['rdf'])
    end
  end
end
#test
