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
    module Filter
      def rdf_container(input, predicate = nil)
        input = rdf_page_to_resource(input)
        return unless valid_resource?(input)
        sparql_client = Jekyll::JekyllRdf::Helper::RdfHelper::sparql
        n_triples = to_string_wrap(input)
        query = "SELECT ?p ?o WHERE{ #{n_triples} " <<
          (predicate.nil? ? "" : " #{rdf_resolve_prefix(predicate)} ?container . ?container ") <<
          " ?p ?o #{query_additions()}"
        solutions = sparql_client.query(query).each_with_object([]) {|solution, array|
          if(/^http:\/\/www\.w3\.org\/1999\/02\/22-rdf-syntax-ns#_\d+$/.match(solution.p.to_s))
            array << Jekyll::JekyllRdf::Drops::RdfTerm.build_term_drop(solution.o, Jekyll::JekyllRdf::Helper::RdfHelper::site, true).add_necessities(Jekyll::JekyllRdf::Helper::RdfHelper::site, Jekyll::JekyllRdf::Helper::RdfHelper::page)
          end
        }
        return solutions
      end

      private
      def query_additions()
        return "BIND((<http://www.w3.org/2001/XMLSchema#integer>(SUBSTR(str(?p), 45))) AS ?order) } ORDER BY ASC(?order)"
      end
    end
  end
end
