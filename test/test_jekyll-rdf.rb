require 'jekyll'
require 'test-unit'
require 'shoulda-context'
require 'rspec/expectations'
require 'pry'

class TestJekyllRdf < Test::Unit::TestCase
  include RSpec::Matchers

  SOURCE_DIR = File.join(File.dirname(__FILE__), "source")
  DEST_DIR   = File.join(SOURCE_DIR, "_site")

  TEST_OPTIONS = {
    'source'         => SOURCE_DIR,
    'destination'    => DEST_DIR,
    'jekyll_rdf'     => {
      'path' => "#{SOURCE_DIR}/rdf-data/simpsons.ttl"
    }
  }
  
  context "Generating a site with RDF data" do
    config = Jekyll.configuration(TEST_OPTIONS)
    site = Jekyll::Site.new(config)
    site.process

    should "have rdf data" do
      assert_not_nil(site.data['rdf'])
    end
    
    should "contain correct age of Homer Simpson" do
      assert site.data['rdf'].include?(['http://www.ifi.uio.no/INF3580/simpsons#Homer','http://xmlns.com/foaf/0.1/age','36'])
    end

    should "create a file which mentions 'Lisa Simpson'" do
      s = File.read("#{DEST_DIR}/index.html")
      expect(s).to include 'Lisa Simpson'
    end
     
  end

end
#test