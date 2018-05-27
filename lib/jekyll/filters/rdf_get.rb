##
# MIT License
#
# Copyright (c) 2016 Elias Saalmann, Christian Frommert, Simon Jakobi,
# Arne Jonas Präger, Maxi Bornmann, Georg Hackel, Eric Füg
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

module Jekyll

  module JekyllRdf

    ##
    # Internal module to hold the method #rdf_get
    #
    module Filter
      def rdf_get(request_uri)
        if (request_uri.class <= Jekyll::JekyllRdf::Drops::RdfResource)
          if(request_uri.covered)
            return request_uri
          else
            return
          end
        end
        request_uri = to_string_wrap(rdf_page_to_resource(request_uri))
        return unless valid_resource?(request_uri) && (!request_uri[0..1].eql? "_:")
        request_uri = rdf_resolve_prefix(request_uri)
        ask_exist = "ASK WHERE {{#{request_uri} ?p ?o}UNION{?s #{request_uri} ?o}UNION{?s ?p #{request_uri}}} "
        return unless (Jekyll::JekyllRdf::Helper::RdfHelper::sparql.query(ask_exist).true?)
        Jekyll::JekyllRdf::Drops::RdfResource.new(RDF::URI(request_uri[1..-2]), Jekyll::JekyllRdf::Helper::RdfHelper::site, Jekyll::JekyllRdf::Helper::RdfHelper::page)
      end
    end
  end
end
