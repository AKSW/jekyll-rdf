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
      # The SPARQL::Client which contains the represented +term+
      #
      attr_reader :sparql

      ##
      # Create a new Jekyll::Drops::RdfTerm
      #
      # * +term+ - The term to be represented
      # * +sparql+ - The SPARQL::Client which contains the represented +term+
      #
      def initialize(term, sparql)
        @term  ||= term
        @sparql ||= sparql
      end

      ##
      # Funktion stub with no funktionality. Its purpose is to keep RdfResource compatible.
      #
      def addNecessities (site, page)
        return self
      end

      ##
      # Funktion stub with no funktionality. Its purpose is to keep RdfResource compatible.
      #
      def ready?
        return true;
      end

      ##
      # Convert this RdfTerm into a string
      # This should be:
      # - for resoruces: the IRI
      # - for literals: the literal representation e.g. "Hallo"@de or "123"^^<http://www.w3.org/2001/XMLSchema#integer>
      #
      def to_s
        term.to_s
      end

      ##
      # Convert an RDF term into a new Jekyll::Drops::RdfTerm
      #
      # * +term+ - The term to be represented
      # * +sparql+ - The SPARQL::Client which contains the represented +term+
      # * +site+ - The Jekyll::Site to be enriched
      #
      def self.build_term_drop(term, sparql, site)
        case term
        when RDF::URI, RDF::Node
          return RdfResource.new(term, sparql)
        when RDF::Literal
          return RdfLiteral.new(term, sparql)
        else
          return nil
        end
      end

    end
  end
end
