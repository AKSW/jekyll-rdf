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
      # Represents an RDF term to the Liquid template engine
      #
      class RdfTerm < Liquid::Drop

        ##
        # The represented RDF term
        #
        attr_reader :term

        ##
        # Create a new Jekyll::JekyllRdf::Drops::RdfTerm
        #
        # * +term+ - The term to be represented
        #
        def initialize(term)
          @term  ||= term
        end

        ##
        # Function stub with no functionality. Its purpose is to keep RdfResource compatible.
        #
        def add_necessities (site, page)
          return self
        end

        ##
        # Function stub with no functionality. Its purpose is to keep RdfResource compatible.
        #
        def ready?
          return true;
        end

        ##
        # Convert this RdfTerm into a string
        # This should be:
        # - for resources: the IRI
        # - for literals: the literal representation e.g. "Hallo"@de or "123"^^<http://www.w3.org/2001/XMLSchema#integer>
        #
        def to_s
          term.to_s
        end

        def ==(other_obj)
          return self.eql? other_obj
        end

        def eql? other_obj
          return (self.to_s.eql? other_obj.to_s)&&((other_obj.class <= self.class)||(self.class <= other_obj.class)||(other_obj.class <= self.term.class))
        end

        def ===(other_obj)
          return self.to_s.eql? other_obj.to_s
        end
        ##
        # Convert an RDF term into a new Jekyll::Drops::RdfTerm
        #
        # * +term+ - The term to be represented
        # * +site+ - The Jekyll::Site to be enriched
        #
        def self.build_term_drop(term, site, covered)
          case term
          when RDF::URI, RDF::Node
            return RdfResource.new(term, site, nil, covered)
          when RDF::Literal
            return RdfLiteral.new(term)
          else
            return nil
          end
        end

        def inspect
          obj_id = ('%x' % (self.object_id << 1)).to_s
          return "#<#{self.class.to_s.split("::")[-1]}:0x#{"0"*(14 - obj_id.length)}#{obj_id} @term=#{@term}>"
        end
      end

    end
  end
end
