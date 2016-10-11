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

module Jekyll #:nodoc:
  module Drops #:nodoc:

    ##
    # Represents an RDF resource class to the Liquid template engine
    #
    class RdfResourceClass < RdfResource
      @subClasses = []
      @lock = -1
      @subClassHierarchyValue = 0
      attr_accessor :lock
      attr_accessor :template
      attr_accessor :subClasses
      attr_accessor :subClassHierarchyValue

      def initialize(term, graph)
        super(term, graph)
        @subClasses= []
        @lock = -1
        @subClassHierarchyValue=0
      end

      def findDirectSubClasses
        selection = statements_as(:object).select{ |s| s.predicate.term.to_s=="http://www.w3.org/2000/01/rdf-schema#subClassOf" }
        return selection
      end

      def addSubClass(resource)
        @subClasses << resource
      end

      def propagateTemplate(template, lock)
        if(@lock>lock||@lock==-1)
          @lock=lock
          @template=template
          subClasses.each{|sub| sub.propagateTemplate(template ,lock+1)}
        end
      end

      def traverseHierarchyValue(predecessorHierarchyValue)
        if(@subClassHierarchyValue + 1>=predecessorHierarchyValue)  #avoid loops
          @subClassHierarchyValue += 1
          subClasses.each{|sub| sub.traverseHierarchyValue(@subClassHierarchyValue)}
        end
      end
    end
  end
end
