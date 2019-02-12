require 'test_helper'

class TestPrefixes < Test::Unit::TestCase
  context "load_prefixes form RdfPageHelper" do
    include RdfTestUtility
    should "map prefixes from the file given through rdf_prefix_path in template frontmatter also for posts" do
      setup_jekyll File.dirname(__FILE__)

      content = []
      file = File.read(File.join(@source, "_site/2019/02/12/Blogpost.html"))
      content = file[/\<body\>(.|\s)*\<\/body\>/][6..-6].strip.split("\n").map do |entry|
        entry.strip
      end

      assert_equal "<h1>My Jekyll RDF Blog</h1>", content[0]
      assert_equal "<p>This is a Blogpost</p>", content[2]
    end
  end
end
