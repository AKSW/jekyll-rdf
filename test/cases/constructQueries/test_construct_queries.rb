require 'test_helper'

class TestSciMath < Test::Unit::TestCase
  include RdfTestUtility
  context "cases/constructQueries" do
    setup do
      setup_jekyll File.dirname(__FILE__)
    end

    should "work with construction queries" do
      content = []
      file = File.read(File.join(@source, "_site/constructs.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal 3, content.length
      nquads = content[0].split("\n")
      assert (nquads.include? "<http://example.org/instance/resource1> <http://contruction.orb/construct> <http://construction.org/constructed> ."), "the return graph should contain >>><http://example.org/instance/resource1> <http://contruction.orb/construct> <http://construction.org/constructed><<<"
      assert (nquads.include? "<http://example.org/instance/resource3> <http://contruction.orb/construct> <http://construction.org/constructed> ."), "the return graph should contain >>><http://example.org/instance/resource3> <http://contruction.orb/construct> <http://construction.org/constructed><<<"
      assert (nquads.include? "<http://example.org/instance/resource2> <http://contruction.orb/construct> <http://construction.org/constructed> ."), "the return graph should contain >>><http://example.org/instance/resource2> <http://contruction.orb/construct> <http://construction.org/constructed><<<"
      nquads = content[1].split("\n")
      assert (nquads.include? "<http://example.org/instance/resource1> <http://contruction.orb/construct> <http://construction.org/constructed> ."), "the return graph should contain >>><http://example.org/instance/resource1> <http://contruction.orb/construct> <http://construction.org/constructed><<<"
      assert (nquads.include? "<http://example.org/instance/resource3> <http://contruction.orb/construct> <http://construction.org/constructed> ."), "the return graph should contain >>><http://example.org/instance/resource3> <http://contruction.orb/construct> <http://construction.org/constructed><<<"
      assert (nquads.include? "<http://example.org/instance/resource2> <http://contruction.orb/construct> <http://construction.org/constructed> ."), "the return graph should contain >>><http://example.org/instance/resource2> <http://contruction.orb/construct> <http://construction.org/constructed><<<"
      ntriples = content[2].split("\n")
      assert (ntriples.include? "<http://example.org/instance/resource1> <http://contruction.orb/construct> <http://construction.org/constructed> ."), "the return graph should contain >>><http://example.org/instance/resource1> <http://contruction.orb/construct> <http://construction.org/constructed><<<"
      assert (ntriples.include? "<http://example.org/instance/resource3> <http://contruction.orb/construct> <http://construction.org/constructed> ."), "the return graph should contain >>><http://example.org/instance/resource3> <http://contruction.orb/construct> <http://construction.org/constructed><<<"
      assert (ntriples.include? "<http://example.org/instance/resource2> <http://contruction.orb/construct> <http://construction.org/constructed> ."), "the return graph should contain >>><http://example.org/instance/resource2> <http://contruction.orb/construct> <http://construction.org/constructed><<<"
    end
  end
end
