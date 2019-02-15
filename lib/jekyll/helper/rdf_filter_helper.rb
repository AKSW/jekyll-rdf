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
    module Helper
      module FilterHelper
        private
        def rdf_page_to_resource(input)
          return Jekyll::JekyllRdf::Helper::RdfHelper::page.data['rdf'] if rdf_substitude_nil?(input)
          return input['rdf'] if rdf_page_to_resource?(input)
          return input
        end

        def rdf_page_to_resource?(input)
          return input.class <= Hash && input.key?("template") && input.key?("url") && input.key?("path") &&!input["rdf"].nil?
        end

        def rdf_substitude_nil?(input)
          return (!Jekyll::JekyllRdf::Helper::RdfHelper::page.data['rdf'].nil?)&&input.nil?
        end

        def valid_resource?(input)
          return (input.class <= String || input.class <= Jekyll::JekyllRdf::Drops::RdfResource)
        end

        def to_string_wrap(input)
          if(input.class <= Jekyll::JekyllRdf::Drops::RdfResource)
            return input.term.to_ntriples
          elsif(input.class <= String)
            return rdf_resolve_prefix(input)
          else
            return false
          end
        end

        def prepare_query(resource = nil, query)
          query = query.clone #sometimes liquid wont reinit static strings in for loops
          if(rdf_substitude_nil?(resource))
            query.gsub!('?resourceUri', "<#{Jekyll::JekyllRdf::Helper::RdfHelper::page.data['rdf'].term}>")
          elsif(resource.class <= Array)
            resource.each_with_index do |uri, index|
              return nil unless valid_resource?(uri)
              if(uri.class <= Jekyll::JekyllRdf::Drops::RdfResource)
                query.gsub!("?resourceUri_#{index}", uri.term.to_ntriples)
              else
                query.gsub!("?resourceUri_#{index}", "#{rdf_resolve_prefix(uri.to_s)}")
              end
            end
          else
            return nil unless valid_resource?(resource)
            query.gsub!('?resourceUri', to_string_wrap(resource))
          end if query.include? '?resourceUri'  #the only purpose of the if statement is to substitute ?resourceUri
          unless Jekyll::JekyllRdf::Helper::RdfHelper::prefixes["rdf_prefixes"].nil?
            query = query.prepend(" ").prepend(Jekyll::JekyllRdf::Helper::RdfHelper::prefixes["rdf_prefixes"])
          end
          return query
        end
      end

      module PrefixSolver
        private
        def rdf_resolve_prefix(predicate)
          if(predicate[0] == "<" && predicate[-1] == ">")
            # iri
            return predicate
          end
          # qname
          arr = predicate.split(":", 2)
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

      module GraphSerializer
        def to_liquid
          return to_nquads
        end

        def to_nquads
          return statements.map{|state|
            state.to_nquads
          }.join("\n")
        end

        def to_ntriples
          return statements.map{|state|
            state.to_ntriples
          }.join("\n")
        end
      end
    end
  end
end

module Jekyll
  module JekyllRdf
    module Filter
      include Jekyll::JekyllRdf::Helper::FilterHelper
      include Jekyll::JekyllRdf::Helper::PrefixSolver
    end
  end
end
