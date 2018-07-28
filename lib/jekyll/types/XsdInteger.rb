module Jekyll
  module JekyllRdf
    module Types
      class XsdInteger
        def self.match? string
          return regex.match string
        end

        def self.regex
          @regex ||= /^[+-]?[0-9]+$/
          return @regex
        end

        def self.to_type string
          return string.to_i.to_s
        end

        def self.=== other
          return other.to_s.eql? "http://www.w3.org/2001/XMLSchema#integer"
        end
      end
    end
  end
end
