module Jekyll
  module JekyllRdf
    module Types
      class XsdBoolean
        def self.match? string
          return regex.match string
        end

        def self.regex
          @regex ||= /^\b1|\b0|\btrue|\bfalse$/
          return @regex
        end

        def self.to_type string
          return "true".eql?(string).to_s
        end

        def self.=== other
          return other.to_s.eql? "http://www.w3.org/2001/XMLSchema#boolean"
        end
      end
    end
  end

end
