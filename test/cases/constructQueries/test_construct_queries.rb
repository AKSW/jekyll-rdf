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
      assert_equal 4, content.length
      assert (content[0].eql?("http://example.org/instance/resource1") || content[0].eql?("http://example.org/instance/resource2") || content[0].eql?("http://example.org/instance/resource3")), "The <div> should contain http://example.org/instance/resource1, http://example.org/instance/resource2 and http://example.org/instance/resource3 at first position.\n It was: >#{content[0]}<."
      assert (content[1].eql?("http://example.org/instance/resource1") || content[1].eql?("http://example.org/instance/resource2") || content[1].eql?("http://example.org/instance/resource3")), "The <div> should contain http://example.org/instance/resource1, http://example.org/instance/resource2 and http://example.org/instance/resource3 at second position.\n It was: >#{content[1]}<."
      assert (content[2].eql?("http://example.org/instance/resource1") || content[2].eql?("http://example.org/instance/resource2") || content[2].eql?("http://example.org/instance/resource3")), "The <div> should contain http://example.org/instance/resource1, http://example.org/instance/resource2 and http://example.org/instance/resource3 at third position.\n It was: >#{content[2]}<."
      assert content.include?("http://example.org/instance/resource1"), "The <div> should include http://example.org/instance/resource1."
      assert content.include?("http://example.org/instance/resource2"), "The <div> should include http://example.org/instance/resource2."
      assert content.include?("http://example.org/instance/resource3"), "The <div> should include http://example.org/instance/resource3."
      assert !content.include?("http://example.org/instance/resource4"), "The <div> should not include http://example.org/instance/resource4."
      assert !content.include?("http://example.org/instance/resource5"), "The <div> should not include http://example.org/instance/resource5."
      assert !content.include?("http://example.org/instance/resource6"), "The <div> should not include http://example.org/instance/resource6."
      nquads = content[3].split("\n\n")
      assert (nquads.include? "<http://example.org/instance/resource1> <http://contruction.orb/construct> <http://construction.org/constructed> ."), "the return graph should contain >>><http://example.org/instance/resource1> <http://contruction.orb/construct> <http://construction.org/constructed><<<"
      assert (nquads.include? "<http://example.org/instance/resource3> <http://contruction.orb/construct> <http://construction.org/constructed> ."), "the return graph should contain >>><http://example.org/instance/resource3> <http://contruction.orb/construct> <http://construction.org/constructed><<<"
      assert (nquads.include? "<http://example.org/instance/resource2> <http://contruction.orb/construct> <http://construction.org/constructed> ."), "the return graph should contain >>><http://example.org/instance/resource2> <http://contruction.orb/construct> <http://construction.org/constructed><<<"
    end
  end
end
