require 'test_helper'

class TestRdfTypes < Test::Unit::TestCase
  context "cases/types" do
    setup do
      @source = File.dirname(__FILE__)
      config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
      site = Jekyll::Site.new(config)
      class Replace
        @@class_uri = "http://example.org/instance/replace"

        def self.match? string
          return regex.match string
        end

        def self.regex
          @@regex ||= /^.*$/
          return @@regex
        end

        def self.to_type string
          return string.gsub(".", "--")
        end

        def self.=== other
          return other.to_s.eql? @@class_uri
        end
      end

      class Revert
        @@class_uri = "http://example.org/instance/revert"

        def self.match? string
          return regex.match string
        end

        def self.regex
          @@regex ||= /^.*$/
          return @@regex
        end

        def self.to_type string
          return string.reverse
        end

        def self.=== other
          return other.to_s.eql? @@class_uri
        end
      end

      class Uppercase
        @@class_uri = "http://example.org/instance/uppercase"

        def self.match? string
          return regex.match string
        end

        def self.regex
          @@regex ||= /^.*$/
          return @@regex
        end

        def self.to_type string
          return string.upcase
        end

        def self.=== other
          return other.to_s.eql? @@class_uri
        end
      end
      Jekyll::JekyllRdf::Helper::Types::register Replace
      Jekyll::JekyllRdf::Helper::Types::register Revert
      Jekyll::JekyllRdf::Helper::Types::register Uppercase
      site.process
    end

    should "evalueate different types" do
      content = []
      file = File.read("#{@source}/_site/types.html")
      content = file[/\<div\>(.|\s)*\<\/div>/][5..-7].strip.split("<br/>").map do |entry|
        entry.strip
      end

      assert_equal "28--07--2018", content[1]
      assert_equal "reverted", content[3]
      assert_equal "THIS WAS ALL LOWER CASE", content[5]
      assert_equal "false", content[7]
      assert_equal "1.0", content[9]
      assert_equal "12", content[11]
      assert_equal "100000", content[13]

      assert_equal "http://www.w3.org/2001/XMLSchema#boolean", Jekyll::JekyllRdf::Types::XsdBoolean.to_s
      assert_equal "http://www.w3.org/2001/XMLSchema#decimal", Jekyll::JekyllRdf::Types::XsdDecimal.to_s
      assert_equal "http://www.w3.org/2001/XMLSchema#integer", Jekyll::JekyllRdf::Types::XsdInteger.to_s
      assert_equal "http://www.w3.org/2001/XMLSchema#double", Jekyll::JekyllRdf::Types::XsdDouble.to_s
    end
  end
end
