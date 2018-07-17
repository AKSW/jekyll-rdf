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
      private
      def rdf_resolve_prefix(predicate)
        if(predicate[0] == "<" && predicate[-1] == ">")
          return predicate
        end
        arr = predicate.split(":", 2) #bad regex, would also devide 'http://example....' into 'http' and '//example....',even though it is already a complete URI; if 'PREFIX http: <http://...> is defined, 'http' in 'http://example....' could be mistaken for a prefix
        if((arr[1].include? (":")) || (arr[1][0..1].eql?("//")))
          raise UnMarkedUri.new(predicate, Jekyll::JekyllRdf::Helper::RdfHelper::page.data['template']) #TODO .data['template'] is only defined on RdfPages
        end
        if(!Jekyll::JekyllRdf::Helper::RdfHelper::prefixes["rdf_prefixes"].nil?)
          if(!Jekyll::JekyllRdf::Helper::RdfHelper::prefixes["rdf_prefix_map"][arr[0]].nil?)
            return "<#{arr[1].prepend(Jekyll::JekyllRdf::Helper::RdfHelper::prefixes["rdf_prefix_map"][arr[0]])}>"
          else
            raise NoPrefixMapped.new(predicate, Jekyll::JekyllRdf::Helper::RdfHelper::page.data['template'], arr[0]) #TODO .data['template'] is only defined on RdfPages
          end
        else
          raise NoPrefixesDefined.new(predicate, Jekyll::JekyllRdf::Helper::RdfHelper::page.data['template']) #TODO .data['template'] is only defined on RdfPages
        end
      end
    end
  end
end
