require 'test_helper'

class TestGeneral < Test::Unit::TestCase
  include RSpec::Matchers
  include RdfTestUtility
  context "Jekyll-Rdf after reinitialization" do
    setup do
      setup_site_jekyll File.dirname(__FILE__)
    end

    should "render content completly" do
      file = File.read(File.join(@source, "_site/reset-page.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "<h4>This is made with jekyll-rdf</h4>", content[0]
      assert_equal "<h6>This is a page</h6>", content[1]
      assert_equal "Test-Page", content[2]
      file = File.read(File.join(@source, "_site/resource1.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "<h4>This is made with jekyll-rdf</h4>", content[0]
      assert_equal "<h6>This is a resource</h6>", content[1]
      assert_equal "http://example.org/instance/resource1", content[2]
      file = File.read(File.join(@source, "_site/resource2.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "<h4>This is made with jekyll-rdf</h4>", content[0]
      assert_equal "<h6>This is a resource</h6>", content[1]
      assert_equal "http://example.org/instance/resource2", content[2]
      Jekyll::JekyllRdf::Helper::RdfHelper.reinitialize
      @site.process
      file = File.read(File.join(@source, "_site/reset-page.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "<h4>This is made with jekyll-rdf</h4>", content[0]
      assert_equal "<h6>This is a page</h6>", content[1]
      assert_equal "Test-Page", content[2]
      file = File.read(File.join(@source, "_site/resource1.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "<h4>This is made with jekyll-rdf</h4>", content[0]
      assert_equal "<h6>This is a resource</h6>", content[1]
      assert_equal "http://example.org/instance/resource1", content[2]
      file = File.read(File.join(@source, "_site/resource2.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "<h4>This is made with jekyll-rdf</h4>", content[0]
      assert_equal "<h6>This is a resource</h6>", content[1]
      assert_equal "http://example.org/instance/resource2", content[2]
    end
  end
end
