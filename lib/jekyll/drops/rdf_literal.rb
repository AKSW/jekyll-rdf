##
# MIT License
#
# Copyright (c) 2016 Elias Saalmann, Christian Frommert, Simon Jakobi,
# Arne Jonas Präger, Maxi Bornmann, Georg Hackel, Eric Füg
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

module Jekyll
  module JekyllRdf
    module Drops

      ##
      # Represents an RDF literal to the Liquid template engine
      #
      class RdfLiteral < RdfTerm

        ##
        # Return a user-facing string representing this RdfLiteral
        #
        def literal
          term.to_s
        end

        ##
        # Return literal value to allow liquid filters to compute
        # rdf literals as well
        #
        def to_liquid
          # Convert scientific notation

          regex = /^(-?)(\d+)\.(\d+)E(-?)(\d+)$/
          numberStr = term.to_s.upcase
          if regex.match(numberStr)

            number = numberStr.to_f

            negative = number < 0

            if negative
              number = number * (-1)
            end

            e = [-1 * (Math.log10(number).floor - (numberStr.to_s.index('E') - numberStr.to_s.index('.'))), 0].max

            vz = ""
            if negative
              vz = "-"
            end

            return vz.to_s + sprintf("%." + e.to_s +  "f\n", number)

          end

          return term.to_s
        end

      end
    end
  end
end
