require 'test_helper'

class TestPrefixes < Test::Unit::TestCase
  context "load_prefixes from RdfPrefixHelper" do
    include RdfTestUtility
    should "check that the prefix search doesnot fail if an undefined layout is specified" do
      setup_jekyll File.dirname(__FILE__)

      blogfile = File.read(File.join(@source, "_site/2019/02/12/Blogpost.html"))
      page = File.read(File.join(@source, "_site/blog.html"))

      #TODO This test case has to be completed once jekyll runs successfull

      assert_equal "<p>This is a Blogpost</p>", blogfile.strip()
      assert_equal "A page", page.strip()
    end
  end
end
