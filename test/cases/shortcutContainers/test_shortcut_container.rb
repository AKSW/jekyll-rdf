require 'test_helper'

class TestShortcutContainer < Test::Unit::TestCase
  include RdfTestUtility
  context "rdf_container" do
    should "accept a resource predicate tupel as pointer (shortcut) to a container" do
      setup_site_jekyll File.dirname(__FILE__)
      file = File.read(File.join(@source, "_site/container.html"))
      answer = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem1"}, "answerset does not contain 'http://example.org/instance/conItem1'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem2"}, "answerset does not contain 'http://example.org/instance/conItem2'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem3"}, "answerset does not contain 'http://example.org/instance/conItem3'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem4"}, "answerset does not contain 'http://example.org/instance/conItem4'")
      assert(answer.any? {|resource| resource.to_s.eql? "http://example.org/instance/conItem5"}, "answerset does not contain 'http://example.org/instance/conItem5'")
    end
  end
end
