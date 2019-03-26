require 'test_helper'

class TestPrefixes < Test::Unit::TestCase
  context "load_prefixes form RdfPageHelper" do
    include RdfTestUtility
    should "map prefixes for posts also when using a gem theme" do
      setup_jekyll File.dirname(__FILE__)

      content = []
      file = File.read(File.join(@source, "_site/2019/02/12/Blogpost.html"))
      content = file[/\<body\>(.|\s)*\<\/body\>/][6..-6].strip.split("<br/>").map do |entry|
        entry.strip
      end

      assert_equal "<h1>My Jekyll RDF Blog</h1>", content[0]
      assert_equal "<p>This is a Blogpost</p>", content[1]
      # this line has to be uncommented once page.rdf is set in posts
      #assert_equal "My Jekyll RDF Blogpost", content[2]
      assert_equal "My Jekyll RDF Blog", content[3]

      content = []
      file = File.read(File.join(@source, "_site/blog.html"))
      content = file[/\<body\>(.|\s)*\<\/body\>/][6..-6].strip.split("<br/>").map do |entry|
        entry.strip
      end

      assert_equal "<h1>My Jekyll RDF Blog</h1>", content[0]
      assert_equal "A page", content[1]
      assert_equal "My Jekyll RDF Blog", content[2]
      assert_equal "My Jekyll RDF Blog", content[3]
    end
  end
end
