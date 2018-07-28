module Jekyll
  module JekyllRdf
    module Types
      class XsdDecimal
        @@class_uri = "http://www.w3.org/2001/XMLSchema#decimal"

        def self.match? string
          return regex.match string
        end

        def self.regex
          @@regex ||= /^[+-]?[0-9]*\.[0-9]+$/
          return @@regex
        end

        def self.to_type string
          return string.to_f.to_s
        end

        def self.=== other
          return other.to_s.eql? @@class_uri
        end

        def self.to_s
          return @@class_uri
        end
      end
    end
  end

end
