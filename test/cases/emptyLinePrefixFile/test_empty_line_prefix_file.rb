require 'test_helper'
require 'yaml'

class TestEmptyLinePrefixFile < Test::Unit::TestCase
  context "cases/emptyLinePrefixFile" do
    should "not raise an exception on encountering an empty line in the prefix file" do
      @source = File.dirname(__FILE__)
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
      assert_nothing_raised do
        Jekyll::Site.new(config)
      end
    end
  end
end
