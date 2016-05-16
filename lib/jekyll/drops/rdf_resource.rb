module Jekyll
  module Drops
    class RdfResource < RdfTerm

      attr_reader :statements, :statements_as_subject, :filename
      attr_accessor :site, :page

      def statements
        @statements ||= statements_as_subject + statements_as_predicate + statements_as_object
      end

      def statements_as_subject
        @statements_as_subject ||= statements_as :subject
      end

      def statements_as_predicate
        @statements_as_predicate ||= statements_as :predicate
      end

      def statements_as_object
        @statements_as_object ||= statements_as :object
      end

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
            while super_class_of t
              s = super_class_of t
              types << s.term.to_s
              t = s
            end
          end
          types
        end
      end

      def super_class_of r
        s = r.statements_as(:subject).find{ |s| s.predicate.term.to_s=="http://www.w3.org/2000/01/rdf-schema#subClassOf" }
        if s
          s.object
        end
      end

      def name
        @name ||= begin
          n = statements_as(:subject).find{ |s| s.predicate.term.to_s=="http://xmlns.com/foaf/0.1/name" }
          n ? n.object.name : term.to_s
        end
      end

      def page_url
        page ? page.url.chomp('index.html') : term.to_s
      end

      def statements_as type
        graph.query(type.to_sym => term).map do |statement|
          RdfStatement.new(statement, graph, site)
        end
      end

      private
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
