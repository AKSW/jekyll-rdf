require 'test-unit'
require 'shoulda-context'
require 'rspec/expectations'
require 'simplecov'
require 'ResourceHelper'
require 'RdfTestUtility'

SimpleCov.formatters = SimpleCov::Formatter::MultiFormatter.new([
  SimpleCov::Formatter::HTMLFormatter,
])
SimpleCov.start do
  add_filter ["/.vendor", "/vendor", "/test"]
end
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
