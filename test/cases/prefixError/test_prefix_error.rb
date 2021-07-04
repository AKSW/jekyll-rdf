require 'test_helper'

class TestPrefixes < Test::Unit::TestCase
  context "load_prefixes form RdfPageHelper" do
    include RdfTestUtility
    should "stop Jekyll if an specified prefix file is not found" do
      test = false
      TestHelper.setErrOutput
      begin
        setup_jekyll File.dirname(__FILE__)
      rescue Errno::ENOENT
        test = true
      end
      TestHelper.resetErrOutput
      assert test, "Jekyll should have been stopped with Errno::ENOENT"
    end
  end
end
