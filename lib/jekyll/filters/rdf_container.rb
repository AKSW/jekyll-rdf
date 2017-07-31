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
      input = Jekyll::RdfHelper::page.data['rdf'] if(input.nil? ||  input.class <= (Jekyll::RdfPageData))
      sparql_client = Jekyll::RdfHelper::sparql
      n_triples = input.term.to_ntriples
      if(!(valid_container?(n_triples, type)))
        Jekyll.logger.error "#{n_triples} is not recognized as a container"
        return []
      end
      query = "SELECT ?p ?o WHERE{ #{n_triples} ?p ?o #{query_additions()}"
      solutions = sparql_client.query(query).each_with_object([]) {|solution, array|
        if(/^http:\/\/www\.w3\.org\/1999\/02\/22-rdf-syntax-ns#_\d+$/.match(solution.p.to_s))
          array << Jekyll::Drops::RdfTerm.build_term_drop(solution.o, Jekyll::RdfHelper::site, true).add_necessities(Jekyll::RdfHelper::site, Jekyll::RdfHelper::page)
        end
      }
      return solutions
    end

    def query_additions()
      return "BIND((<http://www.w3.org/2001/XMLSchema#integer>(SUBSTR(str(?p), 45))) AS ?order) } ORDER BY ASC(?order)"
    end

    def valid_container?(n_triples, type = nil)
      ask_query1 = "ASK WHERE {VALUES ?o {<http://www.w3.org/2000/01/rdf-schema#Container> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Seq> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Bag> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Alt>} #{n_triples} <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?o}"
      ask_query2 = "ASK WHERE {#{ n_triples } <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?o. ?o <http://www.w3.org/2000/01/rdf-schema#subClassOf>* <http://www.w3.org/2000/01/rdf-schema#Container>}"
      return (Jekyll::RdfHelper::sparql.query(ask_query1).true?) || (Jekyll::RdfHelper::sparql.query(ask_query2).true?)
    end
  end
end

Liquid::Template.register_filter(Jekyll::RdfContainer)
