require 'test_helper'

class TestMainGenerator < Test::Unit::TestCase
  include RdfTestUtility
  context "load_config from RdfMainGenerator" do
    should "load baseiri if available" do
      setup_site_jekyll File.dirname(__FILE__)
      assert_equal "http://example.org/", Jekyll::JekyllRdf::Helper::RdfHelper::domainiri
      assert_equal "/instance", Jekyll::JekyllRdf::Helper::RdfHelper::pathiri
    end

    should "fail if template_mapping is defined in _config.yml" do
      TestHelper::setErrOutput
      @source = File.dirname(__FILE__)
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site"), 'jekyll_rdf' => {'template_mapping' => ''}}))
      site = Jekyll::Site.new(config)
      site.process
      assert Jekyll.logger.messages.any? {|message| !!(message =~ /Outdated format in _config\.yml:\n  'template_mapping' detected but the following keys must be used now instead:\n    instance_template_mappings -> maps single resources to single layouts\n    class_template_mappings -> maps entire classes of resources to layouts\nJekyll-RDF wont render any pages for .*/)}, "The generate process should exit with the error message: \nOutdated format in _config.yml:\n  'template_mapping' detected but the following keys must be used now instead:\n    instance_template_mappings -> maps single resources to single layouts\n    class_template_mappings -> maps entire classes of resources to layouts\nJekyll-RDF wont render any pages for \*\*\*\*"
      TestHelper::resetErrOutput
    end
  end
end
