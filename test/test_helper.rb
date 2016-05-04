require 'jekyll'
require 'test-unit'
require 'shoulda-context'
require 'rspec/expectations'
require 'pry'
require 'coveralls'
Coveralls.wear!

class TestHelper

  SOURCE_DIR = File.join(File.dirname(__FILE__), "source")
  DEST_DIR   = File.join(SOURCE_DIR, "_site")

  TEST_OPTIONS = {
    'source'         => SOURCE_DIR,
    'destination'    => DEST_DIR,
    'jekyll_rdf'     => {
      'path' => "#{SOURCE_DIR}/rdf-data/simpsons.ttl",
      'include_blank' => true,
      'restriction' => "SELECT ?s WHERE { ?s ?p ?o }",
      'default_template' => 'rdf_index.html',
      'template_mappings' => {
        'http://xmlns.com/foaf/0.1/Person' => 'person.html',
        'http://www.ifi.uio.no/INF3580/simpsons#Abraham' => 'abraham.html'
      }
    }
  }

end
