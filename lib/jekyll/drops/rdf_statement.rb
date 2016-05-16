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
