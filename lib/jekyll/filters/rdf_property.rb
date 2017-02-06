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
  # Internal module to hold the medthod #rdf_property
  #
  module RdfProperty
    ##
    # Computes all objects for which statements exist containing the given subject and predicate and returns any of them
    #
    # * +input+ - is the subject of the statements to be matched
    # * +predicate+ - is the predicate of the statements to be matched
    # * +lang+ - (optional) preferred language of a the returned object. The precise implementation of choosing which object to return (both in case a language is supplied and in case is not supplied) is undefined
    # * +list+ - (optional) decides the format of the return value. If set to true it returns an array, otherwise it returns a singleton String containing a URI.
    #
    def rdf_property(input, predicate, lang = nil, list = false)
      return input unless input.is_a?(Jekyll::Drops::RdfResource)
      begin
        predicate = rdf_resolve_prefix(input, predicate)
        result = input.statements_as_subject.select{ |s| s.predicate.term.to_s == predicate }
        if lang != nil
          if lang == 'cfg'
            lang = input.site.config['jekyll_rdf']['language']
          end
          result = result.select{ |s|
            if(s.object.term.is_a?(RDF::Literal))
              s.object.term.language == lang.to_sym
            else
              false
            end
          }
        end
        return unless !result.empty?
        if(list)
          return result.map{|p|
            p.object.name.to_s
          }
        else
          return (result.first.object.name).to_s
        end
      end
    end

    private
    def rdf_resolve_prefix(input, predicate)
      if(predicate[0] == "<" && predicate[-1] == ">")
        return predicate[1..-2]
      end
      if(!input.page.data["rdf_prefixes"].nil?)
        arr=predicate.split(":",2)  #bad regex, would also devide 'http://example....' into 'http' and '//example....',even though it is already a complete URI; if 'PREFIX http: <http://...> is defined, 'http' in 'http://example....' could be mistaken for a prefix
        if(!input.page.data["rdf_prefix_map"][arr[0]].nil?)
          return arr[1].prepend(input.page.data["rdf_prefix_map"][arr[0]])
        end
      end
      return predicate
    end
  end
end

Liquid::Template.register_filter(Jekyll::RdfProperty)
