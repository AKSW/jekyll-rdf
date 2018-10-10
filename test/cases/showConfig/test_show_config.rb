require 'test_helper'

class TestShowConfig < Test::Unit::TestCase
  include RdfTestUtility
  context "load_data form RdfPageHelper" do
    should "load data correctly into the file" do
      setup_jekyll File.dirname(__FILE__)

      content = []
      file = File.read(File.join(@source, "_site/resource.html"))
      content = file[/\<div\s*class="instance"\>(.|\s)*\<\/div>/][22..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end

      assert_equal "http://example.org/instance/resource", content[0]
      assert content.include? "http://example.org/instance/resource#subResource1"
      assert content.include? "http://example.org/instance/resource#subResource2"
      assert content.include? "http://example.org/instance/resource#subResource3"
    end
  end
end
