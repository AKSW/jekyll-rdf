module Jekyll
  module JekyllRdf
    module Types
      class XsdDouble
        @@class_uri = "http://www.w3.org/2001/XMLSchema#double"

        def self.match? string
          return regex.match string.upcase
        end

        def self.regex
          @@regex ||= /^[+-]?[0-9]+\.(\d+)E[+-]?(\d+)$/
          return @@regex
        end

        def self.to_type string
          string = string.upcase
          number = string.to_f
          negative = number < 0
          if negative
            number = number * (-1)
          end
          e = [-1 * (Math.log10(number).floor - (string.to_s.index('E') - string.to_s.index('.'))), 0].max
          vz = ""
          if negative
            vz = "-"
          end

          result = vz.to_s + sprintf("%." + e.to_s +  "f", number)
          return result
        end

        def self.=== other
          return other.to_s.eql? @@class_uri
        end

        def self.to_s
          return @@class_uri
        end
      end

      Jekyll::JekyllRdf::Helper::Types::register XsdDouble
    end
  end

end
