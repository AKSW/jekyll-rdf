module Jekyll
  module Drops
    class RdfStatement < Liquid::Drop
      attr_reader :subject, :predicate, :object

      def initialize(statement, graph, site)
        @subject ||= Jekyll::Drops::RdfTerm.build_term_drop(statement.subject, graph, site)
        @predicate ||= Jekyll::Drops::RdfTerm.build_term_drop(statement.predicate, graph, site)
        @object ||= Jekyll::Drops::RdfTerm.build_term_drop(statement.object, graph, site)
      end
    end
  end
end
