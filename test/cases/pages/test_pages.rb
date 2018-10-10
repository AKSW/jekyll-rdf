require 'test_helper'

class TestPages < Test::Unit::TestCase
  include RdfTestUtility
  context "template mapper from RdfPageHelper" do
    setup do
      setup_jekyll File.dirname(__FILE__)
    end

    should "create pages with the correct instance template" do
      file = File.read(File.join(@source, "_site/instance1.html"))
      content = file[/\<div class="map"\>(.|\s)*\<\/div>/][17..-7]
      assert_equal("First Instance Template", content)

      file = File.read(File.join(@source, "_site/instance2.html"))
      content = file[/\<div class="map"\>(.|\s)*\<\/div>/][17..-7]
      assert_equal("Second Instance Template", content)
    end

    should "create pages with the correct class template" do
      file = File.read(File.join(@source, "_site/person.html"))
      content = file[/\<div class="map"\>(.|\s)*\<\/div>/][17..-7]
      assert_equal("First Class Template", content)

      file = File.read(File.join(@source, "_site/classShow.html"))
      content = file[/\<div class="map"\>(.|\s)*\<\/div>/][17..-7]
      assert_equal("Second Class Template", content)
    end

    should "create pages with the default template if no template was found" do
      file = File.read(File.join(@source, "_site/resource.html"))
      content = file[/\<div class="map"\>(.|\s)*\<\/div>/][17..-7]
      assert_equal("Default", content)
    end
  end
end
