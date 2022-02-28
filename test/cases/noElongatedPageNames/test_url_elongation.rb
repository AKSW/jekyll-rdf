require 'test_helper'

class TestNoNameElongation < Test::Unit::TestCase
  include RSpec::Matchers
  include RdfTestUtility
  context "Jekyll-Rdf" do
    setup do
      setup_jekyll File.dirname(__FILE__)
    end

    should "support prefixes on non RdfPages too" do
      file = File.read(File.join(@source, "_site/page.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      # there should be no .html attached to the url, since urls work without it
      assert_equal "/resource", content[0]
    end
  end
end
