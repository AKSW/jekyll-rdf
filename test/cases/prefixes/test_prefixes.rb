require 'test_helper'

class TestPrefixes < Test::Unit::TestCase
  context "load_prefixes form RdfPageHelper" do
    include RdfTestUtility
    setup do
      setup_jekyll File.dirname(__FILE__)
    end

    should "should map prefixes from the file given through rdf_prefix_path in target templates frontmatter" do
      content = []
      file = File.read(File.join(@source, "_site/PrefixDemo.html"))
      content = file[/\<div\s*class="prefixes"\>(.|\s)*\<\/div\>/][22..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end

      assert_equal "eg: http://example.org/instance/_", content[0]
      assert_equal "rdf: http://www.w3.org/1999/02/22-rdf-syntax-ns#_", content[1]
      assert_equal "rdfs: http://www.w3.org/2000/01/rdf-schema#_", content[2]
      assert_equal "xsd: http://www.w3.org/2001/XMLSchema#_", content[3]
      assert_equal "foaf: http://xmlns.com/foaf/0.1/_", content[4]
    end

    should "should map prefixes from the file given through rdf_prefix_path in frontmatters of the entire layout hierarchy" do
      content = []
      file = File.read(File.join(@source, "_site/PrefixDemo2.html"))
      content = file[/\<div\s*class="prefixes"\>(.|\s)*\<\/div\>/][22..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end

      assert_equal "eg: http://example.org/instance/_", content[0]
      assert_equal "rdf: http://www.w3.org/1999/02/22-rdf-syntax-ns#_", content[1]
      assert_equal "rdfs: http://www.w3.org/2000/01/rdf-schema#_", content[2]
      assert_equal "xsd: http://www.w3.org/2001/XMLSchema#_", content[3]
      assert_equal "foaf: http://xmlns.com/foaf/0.1/_", content[4]
    end
  end
end
