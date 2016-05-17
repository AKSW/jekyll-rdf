module Jekyll
  module Drops
    
    ##
    # Represents an RDF literal to the Liquid template engine 
    #
    class RdfLiteral < RdfTerm

      ##
      # Return a user-facing string representing this RdfLiteral
      #
      def name
        term.to_s
      end

    end
  end
end
