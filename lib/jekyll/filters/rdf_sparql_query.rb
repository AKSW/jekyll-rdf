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

  ##
  # Internal module to hold the medthod #sparql_query
  #
  module RdfSparqlQuery

    ##
    # Executes a SPARQL query. The supplied query is augmented by replacing each occurence of '?resourceUri' by the URI of the context RDF resource.
    # Returns an Array of bindings. Each binding is a Hash mapping variables to their values.
    #
    # * +input+ - the context RDF resource
    # * +query+ - the SPARQL query
    #
    def sparql_query(input, query)
      return input unless input.is_a?(Jekyll::Drops::RdfResource)
      query.gsub!('?resourceUri', "<#{input.term.to_s}>")
      if(!input.page.data["rdf_prefixes"].nil?)
        query = query.prepend(" ").prepend(input.page.data["rdf_prefixes"])
      end
      begin
        input.site.data['sparql']
        result = input.site.data['sparql'].query(query).map do |solution|
          hsh = solution.to_h
          hsh.update(hsh){ |k,v| Jekyll::Drops::RdfTerm.build_term_drop(v, input.sparql, input.site).addNecessities(input.site, input.page)}
          hsh.collect{|k,v| [k.to_s, v]}.to_h
        end
        return result
      rescue SPARQL::Client::ClientError => ce
        Jekyll.logger.error("client error experienced: \n #{query} \n Error Message: #{ce.message}")
      rescue SPARQL::MalformedQuery => mq
        Jekyll.logger.error("malformed query found: \n #{query} \n Error Message: #{mq.message}")
      rescue Exception => e
        Jekyll.logger.error("unknown Exception of class: #{e.class} in sparql_query \n Query: #{query} \nMessage: #{e.message}")
      end
      return []
    end

  end
end

Liquid::Template.register_filter(Jekyll::RdfSparqlQuery)
