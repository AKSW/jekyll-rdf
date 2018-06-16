require 'jekyll'
require 'test-unit'
require 'shoulda-context'
require 'rspec/expectations'
require 'pry'
require 'coveralls'
require 'ResourceHelper'
require_relative '../lib/jekyll-rdf'
Coveralls.wear!

Jekyll.logger.log_level = :error
class TestHelper
  BASE_URL   = "/INF3580"
  DOMAIN_NAME = "http://www.ifi.uio.no"
  SOURCE_DIR = File.join(File.dirname(__FILE__), "source")
  DEST_DIR   = File.join(SOURCE_DIR, "_site")
  DUMMY_STDERR = StringIO.new

  TEST_OPTIONS = {
    'source'         => SOURCE_DIR,
    'destination'    => File.join(DEST_DIR, BASE_URL),
    'baseurl'        => BASE_URL,
    'url'            => DOMAIN_NAME,
    'jekyll_rdf'     => {
      'path' => "/rdf-data/simpsons.ttl",
      'language' => 'en',
      'render_orphaned_uris' => true,
      'include_blank' => true,
      'restriction' => 'SELECT ?resourceUri WHERE { ?resourceUri ?p ?o }',
      'default_template' => 'rdf_index',
      'instance_template_mappings' => {
        'http://www.ifi.uio.no/INF3580/simpsons#Abraham' => 'abraham',
        'http://www.ifi.uio.no/INF3580/simpsons#Homer' => 'homer',
        'http://www.ifi.uio.no/INF3580/simpsons' => "family",
        "http://example.org/A" => "test_rdf_get",
        "http://example.org/B" => "test_rdf_get",
        "http://example.org/B#some" => "test_rdf_get",
        "http://example.org/C" => "test_rdf_get"
      },
      'class_template_mappings' => {
        'http://xmlns.com/foaf/0.1/Person' => 'person',
        'http://pcai042.informatik.uni-leipzig.de/~dtp16#AnotherSpecialPerson' => "person",
        'http://pcai042.informatik.uni-leipzig.de/~dtp16#ThirdSpecialPerson' => "person",
        'http://pcai042.informatik.uni-leipzig.de/~dtp16#SpecialPerson' => "person",
        'http://pcai042.informatik.uni-leipzig.de/~dtp16#SimpsonPerson'=> "simpsonPerson"
      }
    }

  }
  def self.setErrOutput
    @@old_stderr = $stderr
    $stderr = DUMMY_STDERR
  end

  def self.resetErrOutput
    $stderr = @@old_stderr
  end
end
