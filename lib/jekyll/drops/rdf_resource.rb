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

      def to_s
        name
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

      private
      def statements_as type
        graph.query(type.to_sym => term).map do |statement|
          RdfStatement.new(statement, graph, site)
        end
      end

      def generate_file_name
        splitted = URI::split(term.to_s)
        cleaned = "#{splitted[2].gsub('.','/')}#{splitted[5]}"
        if splitted[8]
          cleaned += "##{splitted[8]}"
        end
        unless cleaned[-1] == '/'
          cleaned += '/'
        end
        cleaned += 'index.html'
      end

    end
  end
end
