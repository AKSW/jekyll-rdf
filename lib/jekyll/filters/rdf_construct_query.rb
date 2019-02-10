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
    # Internal module to hold the medthod #sparql_query
    #
    module Filter

      ##
      # Executes a CONSTRUCT query. The supplied query is augmented by replacing each occurence of '?resourceUri' by the URI of the context RDF resource.
      # Returns an Array of bindings. Each binding is a Hash mapping variables to their values.
      #
      # * +input+ - the context RDF resource
      # * +query+ - the SPARQL query
      #
      def construct_query(resource = nil, query)
        query = query.clone #sometimes liquid wont reinit static strings in for loops
        if(rdf_substitude_nil?(resource))
          query.gsub!('?resourceUri', "<#{Jekyll::JekyllRdf::Helper::RdfHelper::page.data['rdf'].term}>")
        elsif(resource.class <= Array)
          resource.each_with_index do |uri, index|
            return unless valid_resource?(uri)
            if(uri.class <= Jekyll::JekyllRdf::Drops::RdfResource)
              query.gsub!("?resourceUri_#{index}", uri.term.to_ntriples)
            else
              query.gsub!("?resourceUri_#{index}", "#{rdf_resolve_prefix(uri.to_s)}")
            end
          end
        else
          return unless valid_resource?(resource)
          query.gsub!('?resourceUri', to_string_wrap(resource))
        end if query.include? '?resourceUri'  #the only purpose of the if statement is to substitute ?resourceUri
        new_graph = Jekyll::JekyllRdf::Helper::RdfHelper::sparql.query(query)
        Jekyll::JekyllRdf::Helper::RdfHelper::sparql.insert_data(new_graph)
        return nil
      end
    end
  end
end
