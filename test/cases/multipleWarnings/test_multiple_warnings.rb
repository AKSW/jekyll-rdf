class TestGeneral < Test::Unit::TestCase
  include RSpec::Matchers
  include RdfTestUtility
  context "Jekyll-Rdf template mapping" do
    setup do
      std_dummy = $stderr
      $stderr = StringIO.new
      log_level = Jekyll.logger.level
      Jekyll.logger.log_level = :warn
      setup_jekyll File.dirname(__FILE__)
      Jekyll.logger.log_level = log_level
      $stderr = std_dummy
    end

    should "send warnings only once per " do
      assert  Jekyll.logger.messages.any? {|message|
        (message.include? "Warning: multiple possible templates for resources")&&
        (message.include? "http://example.org/instance/main4")&&
        (message.include? "http://example.org/instance/main3")&&
        (message.include? "Possible Templates:")&&
        (message.include? "layout9")&&
        (message.include? "layout10")&&
        (message.include? "layout11")&&
        (message.include? "layout12")
      }
      assert Jekyll.logger.messages.any? {|message|
        (message.include? "Warning: multiple possible templates for resources")&&
        (message.include? "http://example.org/instance/main1")&&
        (message.include? "Possible Templates:")&&
        (message.include? "layout1")&&
        (message.include? "layout2")&&
        (message.include? "layout3")&&
        (message.include? "layout4")
      }
      assert Jekyll.logger.messages.any? {|message|
        (message.include? "Warning: multiple possible templates for resources")&&
        (message.include? "http://example.org/instance/main2")&&
        (message.include? "Possible Templates:")&&
        (message.include? "layout5")&&
        (message.include? "layout6")&&
        (message.include? "layout7")&&
        (message.include? "layout8")
      }
    end
  end
end
