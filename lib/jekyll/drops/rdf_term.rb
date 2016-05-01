module Jekyll
  module Drops
    class RdfTerm < Liquid::Drop
      attr_reader :term, :graph, :name

      def initialize(term, graph)
        @term ||= term
        @graph ||= graph
      end

      def self.build_term_drop(term, graph, site)
        case term
        when RDF::URI
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
