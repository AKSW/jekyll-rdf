require 'test_helper'

class TestPrefixes < Test::Unit::TestCase
  context "Page merging feature" do
    include RdfTestUtility
    should "also merge posts" do
      setup_jekyll File.dirname(__FILE__)

      content = []
      file = File.read(File.join(@source, "_site/2019/02/12/Blogpost.html"))
      assert !file[/\<body\>(.|\s)*\<\/body\>/].nil?, "The file _site/2019/02/12/Blogpost.html should contain <body> ... </body> if merged correctly."
      content = file[/\<body\>(.|\s)*\<\/body\>/][6..-6].strip.split("<br/>").map do |entry|
        entry.strip
      end

      assert_equal "<h1>My Jekyll RDF Blog</h1>", content[0]
      assert_equal "http://example.org/2019/02/12/Blogpost", content[2]
      assert_equal "This is a Blogpost", content[1]
    end
  end
end
