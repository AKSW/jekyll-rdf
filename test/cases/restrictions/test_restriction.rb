require 'test_helper'

class TestRestriction < Test::Unit::TestCase
  include RSpec::Matchers
  include RdfTestUtility
  context "Jekyll-Rdf restriction model" do
    should "render all resources from the restriction query" do
      @source = File.dirname(__FILE__)
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
      site = Jekyll::Site.new(config)
      Jekyll::JekyllRdf::Helper::RdfHelper.reinitialize
      site.process

      file = File.read(File.join(@source, "_site/resource1.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://example.org/instance/resource1", content[0]
      assert_equal 2, Dir[File.join(@source, '_site/**/*')].length
    end

    should "render all resources from the restriction file" do
      @source = File.dirname(__FILE__)
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
      config["jekyll_rdf"].delete("restriction")
      config["jekyll_rdf"]["restriction_file"] = "_data/restriction-file.rf"
      site = Jekyll::Site.new(config)
      Jekyll::JekyllRdf::Helper::RdfHelper.reinitialize
      site.process

      file = File.read(File.join(@source, "_site/resource2.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://example.org/instance/resource2", content[0]
      assert_equal 2, Dir[File.join(@source, '_site/**/*')].length
    end

    should "render all resources if neither a restriction file nor a restriction query is given" do
      @source = File.dirname(__FILE__)
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
      config["jekyll_rdf"].delete("restriction")
      site = Jekyll::Site.new(config)
      Jekyll::JekyllRdf::Helper::RdfHelper.reinitialize
      site.process

      file = File.read(File.join(@source, "_site/resource1.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://example.org/instance/resource1", content[0]

      file = File.read(File.join(@source, "_site/resource2.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://example.org/instance/resource2", content[0]
      assert_equal 6, Dir[File.join(@source, '_site/**/*')].length
    end

    should "render no resources if the restriction query returns no resources" do
      @source = File.dirname(__FILE__)
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
      config["jekyll_rdf"]["restriction"] = "SELECT ?resourceUri WHERE {?resourceUri ?p <http://example.org/instance/object3>}"
      site = Jekyll::Site.new(config)
      Jekyll::JekyllRdf::Helper::RdfHelper.reinitialize
      site.process

      assert_equal 1, Dir[File.join(@source, '_site/**/*')].length
    end
  end
end
