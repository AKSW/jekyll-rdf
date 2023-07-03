require 'test_helper'

class TestMissingTemplate < Test::Unit::TestCase
  include RdfTestUtility
  context "load_data from RdfPageHelper" do
    should "exit page generation if Jekyll did not load its mapped layout" do   #We can't recreate this case with MWE
      TestHelper::setErrOutput
      setup_jekyll File.dirname(__FILE__)
      assert Jekyll.logger.messages.any?{|message| !!(message=~ /\s*Template .* was not loaded by Jekyll for .*\n\s*Skipping Page.\s*/)}, "missing error message: file not found: ****"
      TestHelper::resetErrOutput
    end
  end
end
