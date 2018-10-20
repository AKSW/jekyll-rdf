require 'test_helper'

class TestShortcutCollections < Test::Unit::TestCase
  include RdfTestUtility
  context "rdf_collection" do
    should "accept a resource predicate tupel as pointer (shortcut) to a collection" do
      setup_site_jekyll File.dirname(__FILE__)
      file = File.read(File.join(@source, "_site/collections.html"))
      answer = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem1"}, "answerset does not contain 'http://example.org/instance/colItem1'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem2"}, "answerset does not contain 'http://example.org/instance/colItem2'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem3"}, "answerset does not contain 'http://example.org/instance/colItem3'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem4"}, "answerset does not contain 'http://example.org/instance/colItem4'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/colItem5"}, "answerset does not contain 'http://example.org/instance/colItem5'")
    end
  end
end
