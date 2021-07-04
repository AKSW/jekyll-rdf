class TestGeneral < Test::Unit::TestCase
  include RSpec::Matchers
  include RdfTestUtility
  context "Jekyll-Rdf" do
    setup do
      setup_jekyll File.dirname(__FILE__)
    end

    should "render all resources, including blanknodes" do
      assert File.exist?(File.join(@source, "_site/predicate.html")), "Jekyll-Rdf did not render _site/predicate.html"
      assert File.exist?(File.join(@source, "_site/object.html")), "Jekyll-Rdf did not render _site/object.html"
      assert File.exist?(File.join(@source, "_site/rdfsites/blanknode/blanknode_resource/index.html")), "Jekyll-Rdf did not render _site/rdfsites/blanknode/blanknode_resource/index.html"
    end
  end
end
