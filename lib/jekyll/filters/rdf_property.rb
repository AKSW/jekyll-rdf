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
    include Jekyll::RdfPrefixResolver
    ##
    # Computes all objects for which statements exist containing the given subject and predicate and returns any of them
    #
    # * +input+ - is the subject of the statements to be matched
    # * +predicate+ - is the predicate of the statements to be matched
    # * +lang+ - (optional) preferred language of a the returned object. The precise implementation of choosing which object to return (both in case a language is supplied and in case is not supplied) is undefined
    # * +list+ - (optional) decides the format of the return value. If set to true it returns an array, otherwise it returns a singleton String containing a URI.
    #
    def rdf_property(input, predicate, lang = nil, list = false)
      return map_predicate(input, predicate, lang, list)
    end

    def rdf_inverse_property(input, predicate, lang = nil, list = false)
      return map_predicate(input, predicate, lang, list, true)
    end

    private
    def map_predicate(input, predicate, lang = nil, list = false, inverse = false)
      return input unless input.is_a?(Jekyll::Drops::RdfResource)
      predicate = rdf_resolve_prefix(input, predicate)
      result = filter_statements(input, predicate, inverse, lang)
      return unless !result.empty?
      if(list)
        return result
      else
        return result.first
      end
    end

    private
    def filter_statements(input, predicate, inverse = false, lang = nil)
      client = input.sparql
      query = ""
      if (lang.eql? 'cfg')
        lang_query = "FILTER(lang(?o) = '#{input.site.config['jekyll_rdf']['language']}')"
      elsif lang.nil?
        lang_query = ""
      else
        lang_query = "FILTER(lang(?o) = '#{lang}')"
      end

      if(!input.to_s[0..1].eql? "_:")
        input_uri = "<#{input.to_s}>"
      else
        input_uri = input.to_s
      end

      if(inverse)
        query = "SELECT ?s WHERE{ ?s <#{predicate}> #{input_uri} }"
        result = client.query(query).map do |solution|
          subject = RDF::URI(solution.s)
          Jekyll::Drops::RdfResource.new(subject, input.sparql, input.site, input.page)
        end
      else
        query = "SELECT ?o ?dt ?lit ?lang WHERE{ #{input_uri} <#{predicate}> ?o BIND(datatype(?o) AS ?dt) BIND(isLiteral(?o) AS ?lit) BIND(lang(?o) AS ?lang) #{lang_query} }"
        result = client.query(query).map do |solution|
          dist_literal_resource(input, solution)
        end
      end
      return result
    end

    ##
    # Distinguishes the solution between an Literal and a Resource
    #
    private
    def dist_literal_resource(input, solution)
      if solution.lit.true?
        check = check_solution(solution)
        object = RDF::Literal(solution.o, language: check[:lang], datatype: RDF::URI(check[:dataType]))
        result = Jekyll::Drops::RdfLiteral.new(object, input.sparql)
      else
        object = RDF::URI(solution.o)
        result = Jekyll::Drops::RdfResource.new(object, input.sparql, input.site, input.page)
      end
      return result
    end

    ##
    # check what language and datatype the passed literal has
    #
    private
    def check_solution(solution)
        result = {:lang => nil, :dataType => nil}
        if((solution.bound?(:lang)) && (!solution.lang.to_s.eql?("")))
          result[:lang] = solution.lang.to_s.to_sym
        end
        if(solution.bound? :dt)
          result[:dataType] = solution.dt
        end
        return result
    end
  end
end

Liquid::Template.register_filter(Jekyll::RdfProperty)
