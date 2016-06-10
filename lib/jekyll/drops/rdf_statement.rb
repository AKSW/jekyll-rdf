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
    # Represents an RDF statement to the Liquid template engine
    #
    class RdfStatement < Liquid::Drop

      ##
      # The subject RdfTerm of this RDF statement
      #
      attr_reader :subject

      ##
      # The predicate RdfTerm of this RDF statement
      #
      attr_reader :predicate

      ##
      # The object RdfTerm of this RDF statement
      #
      attr_reader :object

      ##
      # Create a new Jekyll::Drops::RdfStatement
      #
      # * +statement+ - The statement to be represented
      # * +graph+ - The RDF::Graph which contains the +statement+
      # * +site+ - The Jekyll::Site to be enriched
      def initialize(statement, graph, site)
        @subject ||= Jekyll::Drops::RdfTerm.build_term_drop(statement.subject, graph, site)
        @predicate ||= Jekyll::Drops::RdfTerm.build_term_drop(statement.predicate, graph, site)
        @object ||= Jekyll::Drops::RdfTerm.build_term_drop(statement.object, graph, site)
      end
    end
  end
end
