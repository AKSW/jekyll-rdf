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

    ##
    # Internal module to hold the tag #rdf_link
    #
    module Tag
      class RdfLink < Liquid::Tag
        include Jekyll::JekyllRdf::Filter
        def initialize(tag_name, input, tokens)
          super
          @input = input.strip
        end

        def render(context)
          resource = Jekyll::JekyllRdf::Drops::RdfResource.new(@input[1..-2]) if (@input[0].eql?("<") && @input[-1].eql?(">"))
          resource ||= Jekyll::JekyllRdf::Drops::RdfResource.new(rdf_resolve_prefix(@input)[1..-2]) if @input.include?(':')
          resource ||= context[@input]
          raise ArgumentError.new("No resource found for the given variable #{@input}.") if resource.nil?
          site = Jekyll::JekyllRdf::Helper::RdfHelper::site
          site.each_site_file do |item|
            return item.url if item.relative_path.eql? resource.render_path
            # This takes care of the case for static files that have a leading /
            return item.url if "/#{item.relative_path}".eql? resource.render_path
          end
          raise ArgumentError.new("No file found for #{resource}.")
        end
      end

      Liquid::Template.register_tag('rdf_link', RdfLink)
    end
  end
end
