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
    # * +lang+ - (optional) preferred language of a the returned object. The precise implementation of choosing which object to returned (both in case a language is supplied and in case is not supplied) is undefined
    #
    def rdf_property(input, predicate, lang = nil)
      return input unless input.is_a?(Jekyll::Drops::RdfResource)
      begin
        predicate = rdf_resolve_prefix(input, predicate)
        results = input.page.data['rdf'].statements_as_subject.select{ |s| s.predicate.term.to_s == predicate }
        lang ||= input.site.config['jekyll_rdf']['language']
        if results.count > 1 && lang != nil
          p = results.find{ |s|
            if(s.object.term.is_a?(RDF::Literal))
              s.object.term.language == lang.to_sym
            else
              false
            end
          }
        end
        p = results.first unless p
        return unless p
        (p.object.name).to_s
      end
    end

    ##
    # Computes all objects for which statements exist containing the given subject and predicate and returns an Array of them
    #
    # * +input+ - is the subject of the statements to be matched
    # * +predicate+ - is the predicate of the statements to be matched
    # * +lang+ - (optional) preferred language of the returned objects. If 'cfg' is specified the preferred language is provides by the site configuration _config.yml
    #
    def rdf_property_list(input, predicate, lang = nil)
      return input unless input.is_a?(Jekyll::Drops::RdfResource)
      begin
        predicate = rdf_resolve_prefix(input, predicate)
        result = input.page.data['rdf'].statements_as_subject.select{ |s| s.predicate.term.to_s == predicate } # select all matching statements with given predicate
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
          } # select all statements with matching language
        end
        return unless result
        result.map{|p| p.object.name}
      end
    end

    private
    def rdf_resolve_prefix(input, predicate)
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
