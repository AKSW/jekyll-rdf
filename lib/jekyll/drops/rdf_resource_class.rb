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
  module JekyllRdf #:nodoc:
    module Drops #:nodoc:

      ##
      # Represents an RDF resource class to the Liquid template engine
      #
      class RdfResourceClass < RdfResource
        attr_accessor :lock
        attr_reader :distance #distance to next class with template
        attr_accessor :template
        attr_accessor :path
        attr_accessor :base       # important for template mapping
                                  # true if _config.yml assigned this class a template

        def initialize(term, base = false)
          super(term)
          @base = base
          @lock = -1
          @lockNumber = 0
          @distance = 0
        end

        ##
        # Returns all classes from which +term+ directly inherited
        #
        def find_direct_superclasses
          return @superclasses unless @superclasses.nil?
          query = "SELECT ?s WHERE{ #{@term.to_ntriples} <http://www.w3.org/2000/01/rdf-schema#subClassOf> ?s }"
          selection = Jekyll::JekyllRdf::Helper::RdfHelper::sparql.
            query(query).map{ |solution| solution.s.to_s}
          @superclasses = selection
          return selection
        end

        ##
        # Propagate the current template to the parent of the breadth-first search
        # in RdfClassExtraction.request_class_template.
        #
        def propagate_template(distance)
          return if @path.nil?
          @distance = distance
          return unless @path.template.nil?
          @path.template = @template
          @path.propagate_template(distance +1)
        end

        ##
        # Returns the beginning of the path leading to the found template
        #
        def get_path_root
          return self if @path.nil?
          @path.get_path_root
        end

        ##
        # Checks if this instance was already added to the breadth-first search
        # in RdfClassExtraction.request_class_template.
        #
        def add? lock_number
          if @lock_number != lock_number
            # used to recognize different searchpasses of request_class_template
            @lock_number = lock_number
            @lock = -1
            true
          else
            false
          end
        end
      end #RdfResourceClass
    end
  end
end
