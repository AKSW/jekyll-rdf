module Jekyll
  module JekyllRdf
    module Types
      class XsdInteger
        @@class_uri = "http://www.w3.org/2001/XMLSchema#integer"

        def self.match? string
          return regex.match string
        end

        def self.regex
          @@regex ||= /^[+-]?[0-9]+$/
          return @@regex
        end

        def self.to_type string
          return string.to_i.to_s
        end

        def self.=== other
          return other.to_s.eql? @@class_uri
        end

        def self.to_s
          return @@class_uri
        end
      end

      Jekyll::JekyllRdf::Helper::Types::register XsdInteger
    end
  end
end
