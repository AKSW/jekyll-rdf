require 'test_helper'

class TestRenderedAttribute < Test::Unit::TestCase
  include RdfTestUtility
  context "cases/renderedAttribute" do
    setup do
      setup_jekyll File.dirname(__FILE__)
    end

    should "" do
      content = []
      file = File.read(File.join(@source, "_site/rendered.html"))
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end
      assert "true".eql?(content[0]), "Resource 1 should be true, but it is #{content[0]}"
      assert "true".eql?(content[1]), "Resource 2 should be true, but it is #{content[1]}"
      assert "true".eql?(content[2]), "Resource 3 should be true, but it is #{content[2]}"
      assert "false".eql?(content[3]), "Resource 4 should be false, but it is #{content[3]}"
      assert "false".eql?(content[4]), "Resource 5 should be false, but it is #{content[4]}"
      assert "false".eql?(content[5]), "Resource 6 should be false, but it is #{content[5]}"
      assert "true".eql?(content[6]), "Resource 7 should be false, but it is #{content[6]}"
      assert "false".eql?(content[7]), "Resource 8 should be false, but it is #{content[7]}"
    end
  end
end
