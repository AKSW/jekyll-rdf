module Jekyll
  module Drops
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
      def filename
        @filename ||= generate_file_name
      end

      ##
      # types finds the type and superclasses of the resource
      #
      def types
        @types ||= begin
          types = [ term.to_s ]
          t = statements_as(:subject).find{ |s| s.predicate.term.to_s=="http://www.w3.org/1999/02/22-rdf-syntax-ns#type" }
          if t
            types << t.object.term.to_s
            t = t.object
            while t.super_class
              s = t.super_class
              types << s.term.to_s
              t = s
            end
          end
          types
        end
      end

      ##
      # Return the first super class resource of the receiver or nil, if no super class resource can be found
      #
      def super_class
        s = statements_as(:subject).find{ |s| s.predicate.term.to_s=="http://www.w3.org/2000/01/rdf-schema#subClassOf" }
        if s
          s.object
        end
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
      # Generate a filename corresponding to the RDF resource represented by the receiver. The mapping between RDF resources and filenames should be bijective.
      #
      def generate_file_name
        begin
          uri = URI::split(term.to_s)
          file_name = ""
          (0..8).each do |i|
            if uri[i]
              case i
              when 2
                file_name += "#{uri[i].gsub('.','/')}/"
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
          file_name += 'index.html'
          file_name.gsub('//','/')
        rescue URI::InvalidURIError
          file_name = "blanknode/#{term.to_s}/index.html"
        end
      end

    end
  end
end
