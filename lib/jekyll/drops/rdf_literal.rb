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
        # source: https://github.com/eccenca/jekyll-rdf/commit/704dd98c5e457a81e97fcd011562f1f39fc3f813
        #
        def to_liquid
          # Convert scientific notation

          term_str = term.to_s
          if(term.has_datatype?)
            custom_type = Jekyll::JekyllRdf::Helper::Types::find(term.datatype)
            return custom_type.to_type term_str if (!custom_type.nil?) && (custom_type.match? term_str)
          end
          return term.to_s
        end

      end
    end
  end
end
