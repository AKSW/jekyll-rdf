require 'jekyll'
require 'test-unit'
require 'shoulda-context'

class TestJekyllRdf < Test::Unit::TestCase

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

  end

end
