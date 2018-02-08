# coding: utf-8
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
      def rdf_collection(input, predicate = nil)
        input = rdf_page_to_resource(input)
        return unless valid_resource?(input)
        input = to_string_wrap(input)
        query = "SELECT ?f WHERE{ #{input} " <<
          (predicate.nil? ? "" : " #{rdf_resolve_prefix(predicate)} ?coll . ?coll ") <<
          " <http://www.w3.org/1999/02/22-rdf-syntax-ns#rest>* ?r. ?r <http://www.w3.org/1999/02/22-rdf-syntax-ns#first> ?f}"
        results = []
        Jekyll::JekyllRdf::Helper::RdfHelper::sparql.query(query).each{ |solution|
          results.push Jekyll::JekyllRdf::Drops::RdfTerm.build_term_drop(solution.f, Jekyll::JekyllRdf::Helper::RdfHelper::site, true).add_necessities(Jekyll::JekyllRdf::Helper::RdfHelper::site, Jekyll::JekyllRdf::Helper::RdfHelper::page)
        }
        return results
      end
    end
  end
end
