module Jekyll
  module Drops
    class RdfLiteral < RdfTerm

      attr_reader :name

      def to_s
        term.to_s
      end

      def name
        term.to_s
      end

    end
  end
end
