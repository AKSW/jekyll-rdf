module Jekyll
  module JekyllRdf
    module Types
      class XsdBoolean
        @@class_uri = "http://www.w3.org/2001/XMLSchema#boolean"

        def self.match? string
          return regex.match string
        end

        def self.regex
          @@regex ||= /^\b1|\b0|\btrue|\bfalse$/
          return @@regex
        end

        def self.to_type string
          return "TRUE".eql?(string).to_s
        end

        def self.=== other
          return other.to_s.eql? @@class_uri
        end

        def self.to_s
          return @@class_uri
        end
      end

      Jekyll::JekyllRdf::Helper::Types::register XsdBoolean
    end
  end

end
