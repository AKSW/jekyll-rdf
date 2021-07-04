require 'test_helper'

class TestFaultyConfig < Test::Unit::TestCase
  context "Jekyll-Rdf" do
    include RdfTestUtility
    should "step out of the rendering process if no source-file was provided" do
      @source = File.dirname(__FILE__)
      yaml = YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")})
      yaml["jekyll_rdf"] = yaml["jekyll_rdf"].delete_if {|key, value|
        key.eql? "remote"
      }
      config = Jekyll.configuration(yaml)
      site = Jekyll::Site.new(config)
      Jekyll::JekyllRdf::Helper::RdfHelper.reinitialize
      TestHelper.setErrOutput
      site.process
      TestHelper.resetErrOutput
      assert (Jekyll.logger.messages.any? {|message| !!(message =~/.*No sparql endpoint defined. Jumping out of jekyll-rdf processing.*/)}), ""
    end

    should "throw an ArgumentError if the key remote is specified without a remote endpoint" do
      @source = File.dirname(__FILE__)
      yaml = YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")})
      yaml["jekyll_rdf"] = yaml["jekyll_rdf"].merge({"remote" => {}})
      config = Jekyll.configuration(yaml)
      site = Jekyll::Site.new(config)
      Jekyll::JekyllRdf::Helper::RdfHelper.reinitialize
      TestHelper.setErrOutput
      test = false
      begin
        site.process
      rescue ArgumentError
        test = true
      end
      assert test, "an ArgumentError should have been thrown, since {remote => {}} is specified"
      TestHelper.resetErrOutput
    end
  end
end

