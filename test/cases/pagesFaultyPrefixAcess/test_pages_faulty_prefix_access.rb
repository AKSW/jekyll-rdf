require 'test_helper'

class TestPagesFaultyPrefixAccess < Test::Unit::TestCase
  include RdfTestUtility
  context "load_prefixes form RdfPageHelper" do
    should "raise an error if the given prefixfile is not accessible" do
      TestHelper::setErrOutput
      notFound = false
      begin
        setup_site_jekyll File.dirname(__FILE__)
      rescue Errno::ENOENT
        notFound = true
      end
      assert notFound, "Faulty.pref should not have been found since it doesn't exist."
      assert Jekyll.logger.messages.any?{|message| !!(message=~ /\s*file not found: .*\s*/)}, "missing error message: file not found: ****"
      TestHelper::resetErrOutput
    end
  end
end
