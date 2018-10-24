require 'test_helper'
require 'rest_client'

class TestGeneral < Test::Unit::TestCase
  include RSpec::Matchers
  include RdfTestUtility
  RestClient.post('http://localhost:3030/remote/upload', :name_of_file_param => File.new(File.join(File.dirname(__FILE__), "_data/knowledge-base.ttl")))
  context "A remote sparql endpoint" do
    should "keep rdf_get and rdf_property usable" do
      setup_jekyll File.dirname(__FILE__)
      file = File.read(File.join(@source, "_site/remoteMainTest.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end

      assert_equal "http://remote-endpoint.org/instance/resource", content[0]
      assert_equal "http://remote-endpoint.org/instance/render", content[1]
    end

    should "keep rdf_container usable" do
      setup_jekyll File.dirname(__FILE__)
      file = File.read(File.join(@source, "_site/remoteContainerTest.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end

      assert_equal "http://remote-endpoint.org/instance/conItem1", content[0]
      assert_equal "http://remote-endpoint.org/instance/conItem2", content[1]
      assert_equal "http://remote-endpoint.org/instance/conItem3", content[2]
      assert_equal "http://remote-endpoint.org/instance/conItem4", content[3]
      assert_equal "http://remote-endpoint.org/instance/conItem5", content[4]
    end

    should "keep rdf_collection usable" do
      setup_jekyll File.dirname(__FILE__)
      file = File.read(File.join(@source, "_site/remoteCollectionTest.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end

      assert_equal "http://remote-endpoint.org/instance/colItem1", content[0]
      assert_equal "http://remote-endpoint.org/instance/colItem2", content[1]
      assert_equal "http://remote-endpoint.org/instance/colItem3", content[2]
      assert_equal "http://remote-endpoint.org/instance/colItem4", content[3]
      assert_equal "http://remote-endpoint.org/instance/colItem5", content[4]
    end

    should "keep sparql_query usable" do
      setup_jekyll File.dirname(__FILE__)
      file = File.read(File.join(@source, "_site/remoteQueryTest.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end

      assert(content.any? {|resource| resource.to_s.eql? "http://remote-endpoint.org/instance/queryItem0"}, "answerset does not contain 'http://remote-endpoint.org/instance/queryItem0'")
      assert(content.any? {|resource| resource.to_s.eql? "http://remote-endpoint.org/instance/queryItem1"}, "answerset does not contain 'http://remote-endpoint.org/instance/queryItem1'")
      assert(content.any? {|resource| resource.to_s.eql? "http://remote-endpoint.org/instance/queryItem2"}, "answerset does not contain 'http://remote-endpoint.org/instance/queryItem2'")
    end
  end
end
