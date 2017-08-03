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
  module RdfContainer
    include Jekyll::RdfPrefixResolver
    def rdf_container(input, type = nil)
      sparql_client = input.sparql
      if(!(valid_container?(input, sparql_client, type)))
        Jekyll.logger.error "#{input.term.to_ntriples} is not recognized as a container"
        return []
      end
      query = "SELECT ?p ?o WHERE{ #{input.term.to_ntriples} ?p ?o #{query_additions(input, sparql_client)}"
      solutions = sparql_client.query(query).each_with_object([]) {|solution, array|
        if(/^http:\/\/www\.w3\.org\/1999\/02\/22-rdf-syntax-ns#_\d+$/.match(solution.p.to_s))
          array << Jekyll::Drops::RdfTerm.build_term_drop(solution.o, input.sparql, input.site).add_necessities(input.site, input.page)
        end
      }
      return solutions
    end

    def query_additions(input, sparql_client)
      return "BIND((<http://www.w3.org/2001/XMLSchema#integer>(SUBSTR(str(?p), 45))) AS ?order) } ORDER BY ASC(?order)"
    end

    def valid_container?(input, sparql_client, type = nil)
      ask_query1 = "ASK WHERE {VALUES ?o {<http://www.w3.org/2000/01/rdf-schema#Container> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Seq> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Bag> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Alt>} #{input.term.to_ntriples} <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?o}"
      ask_query2 = "ASK WHERE {#{input.term.to_ntriples} <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?o. ?o <http://www.w3.org/2000/01/rdf-schema#subClassOf>* <http://www.w3.org/2000/01/rdf-schema#Container>}"
      return (sparql_client.query(ask_query1).true?) || (sparql_client.query(ask_query2).true?)
    end
  end
end

Liquid::Template.register_filter(Jekyll::RdfContainer)
