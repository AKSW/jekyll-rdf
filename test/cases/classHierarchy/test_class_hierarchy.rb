require 'test_helper'

class TestClassHierarchy < Test::Unit::TestCase
  include RdfTestUtility
  context "the class-template-mapping system" do
    should "map the right template to the right class in consideration to its super classes" do
      setup_jekyll File.dirname(__FILE__)

      content = []
      file = File.read(File.join(@source, "_site/baseRes.html"))
      content = file[/\<div class="mapping"\>(.|\s)*\<\/div>/][21..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://example.org/instance/baseRes", content[0]
      assert_equal "LowerMaster", content[1]

      content = []
      file = File.read(File.join(@source, "_site/advaRes.html"))
      content = file[/\<div class="mapping"\>(.|\s)*\<\/div>/][21..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://example.org/instance/advaRes", content[0]
      assert_equal "Advanced", content[1]

      content = []
      file = File.read(File.join(@source, "_site/mastRes.html"))
      content = file[/\<div class="mapping"\>(.|\s)*\<\/div>/][21..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://example.org/instance/mastRes", content[0]
      assert_equal "Master", content[1]

      content = []
      file = File.read(File.join(@source, "_site/suprRes.html"))
      content = file[/\<div class="mapping"\>(.|\s)*\<\/div>/][21..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert_equal "http://example.org/instance/suprRes", content[0]
      assert_equal "Supreme", content[1]
      #subclasshier... used in map -> problem: subclasses do not get the same template | class to class is not influenced by classHier... only instance to class
    end
  end
end
