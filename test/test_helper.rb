require 'jekyll'
require 'test-unit'
require 'shoulda-context'
require 'rspec/expectations'
require 'pry'
require 'coveralls'
require 'ResourceHelper'
require 'RdfTestUtility'

Coveralls.wear!
require_relative '../lib/jekyll-rdf'

Jekyll.logger.log_level = :error
class TestHelper
  DUMMY_STDERR = StringIO.new

  def self.setErrOutput
    @@old_stderr = $stderr
    $stderr = DUMMY_STDERR
  end

  def self.resetErrOutput
    $stderr = @@old_stderr
  end
end
