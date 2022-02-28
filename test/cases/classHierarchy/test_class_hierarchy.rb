require 'test_helper'

class TestClassHierarchy < Test::Unit::TestCase
  include RdfTestUtility
  context "the class-template-mapping system" do
    should "map the right template to the right class in consideration to its super classes" do
      error_holder = $stderr
      Jekyll.logger.log_level = :warn
      $stderr = StringIO.new
      setup_jekyll File.dirname(__FILE__)
      Jekyll.logger.log_level = :error
      $stderr = error_holder

      content = []
      file = File.read(File.join(@source, "_site/Fish.html"))
      content = file[/\<div class="mapping"\>(.|\s)*\<\/div>/][21..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://animals.org/instance/Fish", content[0]
      assert_equal "foodFromWater", content[1]

      content = []
      file = File.read(File.join(@source, "_site/Lizard.html"))
      content = file[/\<div class="mapping"\>(.|\s)*\<\/div>/][21..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://animals.org/instance/Lizard", content[0]
      assert_equal "landBorn", content[1]

      content = []
      file = File.read(File.join(@source, "_site/Penguins.html"))
      content = file[/\<div class="mapping"\>(.|\s)*\<\/div>/][21..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://animals.org/instance/Penguins", content[0]
      assert (("foodFromWater".eql? content[1]) || ("layingEggs".eql? content[1]))

      content = []
      file = File.read(File.join(@source, "_site/Whale.html"))
      content = file[/\<div class="mapping"\>(.|\s)*\<\/div>/][21..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://animals.org/instance/Whale", content[0]
      assert_equal "breathingAir", content[1]

      content = []
      file = File.read(File.join(@source, "_site/ape.html"))
      content = file[/\<div class="mapping"\>(.|\s)*\<\/div>/][21..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://animals.org/instance/ape", content[0]
      assert_equal "landBorn", content[1]

      assert Jekyll.logger.messages.any? {|message| !!(message =~ /.*Warning: multiple possible templates for resources.*Penguins.*/)}, "This warning should have been thrown >>>Warning: multiple possible templates for resources http://animals.org/instance/Penguins Possible Templates: foodFromWater, layingEggs<<<"
      assert !Jekyll.logger.messages.any? {|message| !!(message =~ /.*Warning: multiple possible templates for resources.*Fish.*/)}, "This warning should not have been thrown >>>Warning: multiple possible templates for resources http://animals.org/instance/Fish Possible Templates: ***<<<"
    end
  end
end
