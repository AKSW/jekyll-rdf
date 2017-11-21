module Jekyll
  module JekyllRdf
    module Filter
      private
      def rdf_page_to_resource(input)
        return Jekyll::JekyllRdf::Helper::RdfHelper::page.data['rdf'] if(rdf_page_to_resource?(input))
        return input
      end

      def rdf_page_to_resource?(input)
        return (!Jekyll::JekyllRdf::Helper::RdfHelper::page.data['rdf'].nil?)&&(input.nil? ||  input.class <= (Jekyll::RdfPageData) || (input.class <= Hash && input.respond_to?(:template) && input.respond_to?(:url) && input.respond_to?(:path) ))
      end

      def valid_resource?(input)
        return (input.class <= String || input.class <= Jekyll::JekyllRdf::Drops::RdfResource)
      end
    end
  end
end
