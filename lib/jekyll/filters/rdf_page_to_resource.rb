module Jekyll
  module JekyllRdf
    module Filter
      private
      def rdf_page_to_resource(input)
        return Jekyll::JekyllRdf::Helper::RdfHelper::page.data['rdf'] if rdf_substitude_nil?(input)
        return input['rdf'] if rdf_page_to_resource?(input)
        return input
      end

      def rdf_page_to_resource?(input)
        return input.class <= Hash && input.key?("template") && input.key?("url") && input.key?("path") &&!input["rdf"].nil?
      end

      def rdf_substitude_nil?(input)
        return (!Jekyll::JekyllRdf::Helper::RdfHelper::page.data['rdf'].nil?)&&input.nil?
      end

      def valid_resource?(input)
        return (input.class <= String || input.class <= Jekyll::JekyllRdf::Drops::RdfResource)
      end

      def to_string_wrap(input)
        if(input.class <= Jekyll::JekyllRdf::Drops::RdfResource)
          return input.term.to_ntriples
        elsif(input.class <= String)
          return rdf_resolve_prefix(input)
        else
          return false
        end
      end
    end
  end
end
