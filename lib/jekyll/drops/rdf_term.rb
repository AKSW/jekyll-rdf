module Jekyll
  module Drops
  
    ##
    # Represents an RDF term to the Liquid template engine 
    #
    class RdfTerm < Liquid::Drop
      
      ##
      # The represented RDF term
      #
      attr_reader :term

      ##
      # The RDF::Graph which contains the represented +term+
      #
      attr_reader :graph

      ##
      # Create a new Jekyll::Drops::RdfTerm
      # 
      # * +term+ - The term to be represented
      # * +graph+ - The graph which contains the represented +term+
      #
      def initialize(term, graph)
        @term  ||= term
        @graph ||= graph
      end

      def self.build_term_drop(term, graph, site)
        case term
        when RDF::URI, RDF::Node
          if site
            resource = site.data['resources'].find{ |r| r.term == term }
          end
          resource ? resource : RdfResource.new(term, graph)
        when RDF::Literal
          return RdfLiteral.new(term, graph)
        else
          return nil
        end
      end

    end
  end
end
