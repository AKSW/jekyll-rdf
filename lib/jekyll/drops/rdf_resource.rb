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
    # Represents an RDF resource to the Liquid template engine
    #
    class RdfResource < RdfTerm

      ##
      # The Jekyll::Site of this Jekyll::Drops::RdfResource
      #
      attr_accessor :site

      ##
      # The Jekyll::RdfPageData of this Jekyll::Drops::RdfResource
      #
      attr_accessor :page

      ##
      # Return a list of Jekyll::Drops::RdfStatements whose subject, predicate or object is the RDF resource represented by the receiver
      #
      def statements
        @statements ||= statements_as_subject + statements_as_predicate + statements_as_object
      end

      ##
      # Return a list of Jekyll::Drops::RdfStatements whose subject is the RDF resource represented by the receiver
      #
      def statements_as_subject
        @statements_as_subject ||= statements_as :subject
      end

      ##
      # Return a list of Jekyll::Drops::RdfStatements whose predicate is the RDF resource represented by the receiver
      #
      def statements_as_predicate
        @statements_as_predicate ||= statements_as :predicate
      end

      ##
      # Return a list of Jekyll::Drops::RdfStatements whose object is the RDF resource represented by the receiver
      #
      def statements_as_object
        @statements_as_object ||= statements_as :object
      end

      ##
      # Return a filename corresponding to the RDF resource represented by the receiver. The mapping between RDF resources and filenames should be bijective.
      #
      def filename(domain_name, baseurl)
        @filename ||= generate_file_name(domain_name, baseurl)
      end

      ##
      # types finds the type and superclasses of the resource
      #
      def types
        @types ||= begin
          types = [ term.to_s ]
          selection = statements_as(:subject).select{ |s| s.predicate.term.to_s=="http://www.w3.org/1999/02/22-rdf-syntax-ns#type" }
          unless selection.empty?
            t = selection.first
            if selection.count > 1
              Jekyll.logger.warn "Resource #{name} has multiple RDFS types. Will use #{t.object.term.to_s} for template mapping.  "
            end
            types << t.object.term.to_s
            t = t.object
            s = t.super_class
            while s
              types << s.term.to_s
              s = s.super_class
            end
          end
          types
        end
      end

      def directClasses
        @directClasses ||= begin
          classes=[]
          selection = statements_as(:subject).select{ |s| s.predicate.term.to_s=="http://www.w3.org/1999/02/22-rdf-syntax-ns#type" }
          unless selection.empty?
            selection.each{|s| classes << s.object.term.to_s}
          end
          classes.uniq!
          classes
        end
      end

      ##
      # Return the first super class resource of the receiver or nil, if no super class resource can be found
      #
      def super_class
        selection = statements_as(:subject).select{ |s| s.predicate.term.to_s=="http://www.w3.org/2000/01/rdf-schema#subClassOf" }
        unless selection.empty?
          super_class = selection.first
          if selection.count > 1
            Jekyll.logger.warn "Type #{name} has multiple RDFS super classes. Will use #{super_class.object.term.to_s} for template mapping.  "
          end
          super_class.object
        end
      end


      def is_a_resource_class?
        selection = statements_as(:object).select{ |s|
          s.predicate.term.to_s=="http://www.w3.org/1999/02/22-rdf-syntax-ns#type"||s.predicate.term.to_s=="http://www.w3.org/2000/01/rdf-schema#subClassOf"
        }
        unless selection.empty?
          return true
        end
        return false
      end

      ##
      # Return a user-facing string representing this RdfResource
      #
      def name
        @name ||= begin
          n = statements_as(:subject).find{ |s| s.predicate.term.to_s=="http://xmlns.com/foaf/0.1/name" }
          n ? n.object.name : term.to_s
        end
      end

      ##
      # Return the URL of the page representing this RdfResource
      #
      def page_url
        page ? page.url.chomp('index.html') : term.to_s
      end

      ##
      # Return a list of RDF statements where the represented RDF resource plays a role
      # * +role+ - which role the represented RDF resource should play:
      #   :subject ::
      #     Return a list of Jekyll::Drops::RdfStatements whose subject is the RDF resource represented by the receiver
      #   :predicate ::
      #     Return a list of Jekyll::Drops::RdfStatements whose predicate is the RDF resource represented by the receiver
      #   :object ::
      #     Return a list of Jekyll::Drops::RdfStatements whose object is the RDF resource represented by the receiver
      #
      def statements_as(role)
        graph.query(role.to_sym => term).map do |statement|
          RdfStatement.new(statement, graph, site)
        end
      end

      private
      ##
      # Generate a filename corresponding to the RDF resource represented by the receiver. The mapping between RDF resources and filenames should be bijective. If the url of the rdf is the same as of the hosting site it will be omitted.
      # * +domain_name+
      #
      def generate_file_name(domain_name, baseurl)
        begin
          uri = URI::split(term.to_s)
          file_name = "rdfsites/" # in this directory all external RDF sites are stored
          if (uri[2] == domain_name)
            file_name = ""
            uri[0] = nil
            uri[2] = nil
            uri[5] = uri[5].sub(baseurl,'')
          end
          (0..8).each do |i|
            if uri[i]
              case i
              when 5
                file_name += "#{uri[i][1..-1]}"
              when 8
                file_name = file_name[0..-2]
                file_name += "##{uri[i]}"
              else
                file_name += "#{uri[i]}/"
              end
            end
          end
          unless file_name[-1] == '/'
            file_name += '/'
          end

          file_name =file_name.gsub('_','_u')
          file_name =file_name.gsub('.','_d')
          file_name += 'index.html'
          file_name =file_name.gsub('//','/_/') # needs a better regex to include /// ////...
          file_name =file_name.gsub(':','_D')
          file_name
        rescue URI::InvalidURIError
          file_name = "rdfsites/blanknode/#{term.to_s}/index.html"
        end
      end

    end
  end
end
