class TestPages < Test::Unit::TestCase
  include RdfTestUtility
  context "Jekyll logger" do
    setup do
      Jekyll.logger.log_level = :debug
      old_err_out = $stderr
      old_std_out = $stdout
      dummy_out = StringIO.new
      $stderr = dummy_out
      $stdout = dummy_out
      setup_jekyll File.dirname(__FILE__)
      $stderr = old_err_out
      $stdout = old_std_out
      Jekyll.logger.log_level = :error
    end

    should "contain messages" do
      assert (Jekyll.logger.messages.any? {|message| !!(message =~/.*Info message.*/)}), "Jekyll.logger should contain message: >>>Info message<<<"
      assert (Jekyll.logger.messages.any? {|message| !!(message =~/.*Warn message.*/)}), "Jekyll.logger should contain message: >>>Warn message<<<"
      assert (Jekyll.logger.messages.any? {|message| !!(message =~/.*Error message.*/)}), "Jekyll.logger should contain message: >>>Error message<<<"
      assert (Jekyll.logger.messages.any? {|message| !!(message =~/.*Debug message.*/)}), "Jekyll.logger should contain message: >>>Debug message<<<"
      assert (Jekyll.logger.messages.any? {|message| !!(message =~/.*NoLevel: message.*/)}), "Jekyll.logger should contain message: >>>NoLevel: message<<<"
    end
  end
end
