require 'test_helper'

class TestRenderedAttribute < Test::Unit::TestCase
  include RdfTestUtility
  context "cases/uniqueResources" do
    setup do
      setup_jekyll File.dirname(__FILE__)
    end

    should "create only one resource" do
      content = []
      file = File.read(File.join(@source, "_site/uniqueResources.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://example.org/instance/resource", content[0]
      assert_equal "http://example.org/instance/resource", content[1]
      assert_equal "http://example.org/instance/resource", content[2]
      resources = Jekyll::JekyllRdf::Helper::RdfHelper.class_variable_get(:@@resources)
      assert resources.length.eql? 1
    end
  end
end