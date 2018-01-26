module Jekyll
  module JekyllRdf

    ##
    # Internal module to hold the medthod #rdf_get
    #
    module Filter
      def rdf_make_array(array_string)
        array_string.strip!
        array_string.rstrip!
        array_string = check_allowed(array_string)
        array_string.split(",").each{|uri_string|
          uri_string.strip!
          uri_string.rstrip!
          if ((uri_string[0].eql? "<")&&(uri_string[-1].eql? ">"))&&(uri_string[1..-2] =~ /\A#{URI::regexp}\z/) # uncomment if regex actually works
            uri_string#[1..-2]
          else
            raise InvalidURI.new(uri_string)
          end
        }
      end

      private
      def check_allowed(array_string)
        if((array_string[0].eql? "[")&&(array_string[-1].eql? "]"))
          return array_string[1..-2]
        end
        raise InvalidArrayString.new(array_string)
      end
    end
  end
end
