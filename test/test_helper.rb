require 'jekyll'
require 'test-unit'
require 'shoulda-context'
require 'rspec/expectations'
require 'pry'
require 'coveralls'
require 'ResourceHelper'
require_relative '../lib/jekyll-rdf'
Coveralls.wear!

class TestHelper
  BASE_URL   = "/INF3580"
  DOMAIN_NAME = "http://www.ifi.uio.no"
  SOURCE_DIR = File.join(File.dirname(__FILE__), "source")
  DEST_DIR   = File.join(SOURCE_DIR, "_site")

  TEST_OPTIONS = {
    'source'         => SOURCE_DIR,
    'destination'    => File.join(DEST_DIR, BASE_URL),
    'baseurl'        => BASE_URL,
    'url'            => DOMAIN_NAME,
    'jekyll_rdf'     => {
      'path' => "#{SOURCE_DIR}/rdf-data/simpsons.ttl",
      'language' => 'en',
      'render_orphaned_uris' => true,
      'include_blank' => true,
      'restriction' => 'SELECT ?resourceUri WHERE { ?resourceUri ?p ?o }',
      'default_template' => 'rdf_index.html',
      'instance_template_mappings' => {
        'http://www.ifi.uio.no/INF3580/simpsons#Abraham' => 'abraham.html',
        'http://www.ifi.uio.no/INF3580/simpsons#Homer' => 'homer.html',
        'http://www.ifi.uio.no/INF3580/simpsons' => "family.html"
      },
      'class_template_mappings' => {
        'http://xmlns.com/foaf/0.1/Person' => 'person.html',
        'http://pcai042.informatik.uni-leipzig.de/~dtp16/#AnotherSpecialPerson' => "person.html",
        'http://pcai042.informatik.uni-leipzig.de/~dtp16/#ThirdSpecialPerson' => "person.html",
        'http://pcai042.informatik.uni-leipzig.de/~dtp16/#SpecialPerson' => "person.html",
        'http://pcai042.informatik.uni-leipzig.de/~dtp16/#SimpsonPerson'=> "simpsonPerson.html"
      }
    }
  }

end
