module Jekyll
  module Drops
    
    ##
    # Represents a RDF statement to the Liquid template engine
    #
    class RdfStatement < Liquid::Drop
      attr_reader :subject
      attr_reader :predicate
      attr_reader :object

      def initialize(statement, graph, site)
        @subject ||= Jekyll::Drops::RdfTerm.build_term_drop(statement.subject, graph, site)
        @predicate ||= Jekyll::Drops::RdfTerm.build_term_drop(statement.predicate, graph, site)
        @object ||= Jekyll::Drops::RdfTerm.build_term_drop(statement.object, graph, site)
      end
    end
  end
end
