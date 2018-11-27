require 'test_helper'

class TestGeneral < Test::Unit::TestCase
  include RSpec::Matchers
  include RdfTestUtility
  context "Jekyll-Rdf" do
    setup do
      setup_jekyll File.dirname(__FILE__)
    end

    should "only render the resources given in _data/restrictions.txt" do
      assert File.exist?(File.join(File.dirname(__FILE__),'_site/listResource1.html')), "listResource1 was in the render list _data/restriction.txt, but wasn't rendered"
      assert File.exist?(File.join(File.dirname(__FILE__),'_site/listResource2.html')), "listResource2 was in the render list _data/restriction.txt, but wasn't rendered"
      assert File.exist?(File.join(File.dirname(__FILE__),'_site/listResource3.html')), "listResource3 was in the render list _data/restriction.txt, but wasn't rendered"
      assert !File.exist?(File.join(File.dirname(__FILE__),'_site/unlistResource1.html')), "unlistResource1 wasn't in the render list _data/restriction.txt, but was rendered"
      assert !File.exist?(File.join(File.dirname(__FILE__),'_site/unlistResource2.html')), "unlistResource2 wasn't in the render list _data/restriction.txt, but was rendered"
      assert !File.exist?(File.join(File.dirname(__FILE__),'_site/unlistResource3.html')), "unlistResource3 wasn't in the render list _data/restriction.txt, but was rendered"
    end
  end
end
