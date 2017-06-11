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
      sparqlClient = input.sparql
      if(!(validContainer?(input, sparqlClient, type)))
        Jekyll.logger.error "<#{input.iri}> is not recognized as a container"
        return []
      end
      query = "SELECT ?p ?o WHERE{ <#{input.iri}> ?p ?o }"
      solutions = sparqlClient.query(query).each_with_object([]) {|solution, array|
        if((solution.p.to_s[0..43].eql? "http://www.w3.org/1999/02/22-rdf-syntax-ns#_") && (solution.p.to_s[44..-1] !~ /\D/))
          array << Jekyll::Drops::RdfTerm.build_term_drop(solution.o, input.sparql, input.site).addNecessities(input.site, input.page)
        end
      }
      return solutions
    end
    def validContainer?(input, sparqlClient, type = nil)
      askQuery1 = "ASK WHERE {VALUES ?o {<http://www.w3.org/1999/02/22-rdf-syntax-ns#Seq> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Bag> <http://www.w3.org/1999/02/22-rdf-syntax-ns#Alt>} <#{input.iri}> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?o}"
      askQuery2 = "ASK WHERE {<#{input.iri}> <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?o. ?o <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> <http://www.w3.org/2000/01/rdf-schema#Container>}"
      return (sparqlClient.query(askQuery1).true?) || (sparqlClient.query(askQuery2).true?)
    end
  end
end

Liquid::Template.register_filter(Jekyll::RdfContainer)
