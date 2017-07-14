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
      attr_accessor :alternativeTemplates
      attr_accessor :subClasses
      attr_accessor :subClassHierarchyValue

      def initialize(term, sparql)
        super(term, sparql)
        @subClasses = []
        @lock = -1
        @subClassHierarchyValue = 0
        @alternativeTemplates = []
      end

      def multiple_templates?
        !@alternativeTemplates.empty?
      end

      def find_direct_subclasses
        if(!@term.to_s[0..1].eql? "_:")
          term_uri = "<#{@term.to_s}>"
        else
          term_uri = @term.to_s
        end
        query = "SELECT ?s WHERE{ ?s <http://www.w3.org/2000/01/rdf-schema#subClassOf> #{term_uri}}"
        selection = @sparql.query(query).map{ |solution| solution.s.to_s}
        return selection
      end

      def add_subclass(resource)
        @subClasses << resource
      end

      def propagate_template(template, lock)
        if(@lock>lock||@lock==-1)
          @lock=lock
          @template=template
          @alternativeTemplates.clear()
          subClasses.each{|sub| sub.propagate_template(template ,lock+1)}
        elsif(@lock==lock)
          @alternativeTemplates.push(template)
          subClasses.each{|sub| sub.propagate_template(template ,lock+1)}
        end
      end

      def traverse_hierarchy_value(predecessorHierarchyValue)
        if(@subClassHierarchyValue + 1 >= predecessorHierarchyValue)  #avoid loops
          @subClassHierarchyValue += 1
          subClasses.each{|sub| sub.traverse_hierarchy_value(@subClassHierarchyValue)}
        end
      end
    end
  end
end
