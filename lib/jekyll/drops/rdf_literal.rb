module Jekyll
  module Drops
    
    ##
    # Represents an RDF literal to the Liquid template engine 
    #
    class RdfLiteral < RdfTerm

      def to_s
        term.to_s
      end

      def name
        term.to_s
      end

    end
  end
end
