require 'test_helper'

class TestMainPrefixFile < Test::Unit::TestCase
  include RSpec::Matchers
  include RdfTestUtility

  context "The main prefix file" do
    should "support prefixes on non RdfPages too" do
      setup_jekyll File.dirname(__FILE__)
      file = File.read(File.join(@source, "_site/mainPrefixTest.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://xmlns.com/foaf/0.1/resource", content[0]
      assert_equal "http://example.org/instance/resource", content[1]
      assert_equal "http://www.w3.org/2001/XMLSchema#resource", content[2]
      assert_equal "http://www.w3.org/2000/01/rdf-schema#resource", content[3]
      assert_equal "http://www.w3.org/1999/02/22-rdf-syntax-ns#resource", content[4]
    end
  end

end
