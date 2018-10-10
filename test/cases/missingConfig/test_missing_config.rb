require 'test_helper'

class TestMainGeneratorMissingConfig < Test::Unit::TestCase
  include RdfTestUtility
  context "load_config from RdfMainGenerator" do
    should "fail if jekyll-rdf is included but not configured" do
      TestHelper::setErrOutput
      @source = File.dirname(__FILE__)
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
      site = Jekyll::Site.new(config)
      site.process
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /You've included Jekyll-RDF, but it is not configured. Aborting the jekyll-rdf plugin./)}, "The should exit with the error message: ''You've included Jekyll-RDF, but it is not configured. Aborting the jekyll-rdf plugin.''"
      TestHelper::resetErrOutput
    end
  end
end