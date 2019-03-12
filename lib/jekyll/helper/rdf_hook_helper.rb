##
# MIT License
#
# Copyright (c) 2017 Sebastian Zänker
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
      module RdfHookHelper
        def backload_prefixes page, payload
          prefix_path = page.data["rdf_prefix_path"]
          begin
            if(!prefix_path.nil? && !page.data["rdf_prefix_set?"] && !page.data["layout"].nil?)
              # rdf_prefix_path is set but not defined through the page
              base_path = search_prefix_definition page.site.layouts[page.data["layout"]], prefix_path
            elsif (prefix_path.nil? && !page.data["layout"].nil?)
              # page might be a post (does not contain values from layout frontmatter)
              # |->rdf_prefix_path can still be set in a layout
              locations = check_prefix_definition page.site.layouts[page.data["layout"]]
              base_path = locations[0]
              prefix_path = locations[1]
            elsif(!prefix_path.nil? && page.data["rdf_prefix_set?"])
              # rdf_prefix_path is set directly in the fronmatter of the page
              base_path = page.instance_variable_get(:@base_dir)
              base_path ||= payload.site["source"]
            end
          rescue NoMethodError => ne
            #just in case the error was caused by something different then a missing template
            if(ne.message.eql? "undefined method `data' for nil:NilClass")
              return
            else
              raise
            end
          end
          if(page.data["rdf_prefixes"].nil? && !(prefix_path.nil? || base_path.nil?))
            Jekyll::JekyllRdf::Helper::RdfHelper.load_prefixes(
              File.join(
                base_path,
                prefix_path
              ),
              page.data
            )
          end
        end

        def search_prefix_definition layout, rdf_prefix_path
          if(rdf_prefix_path.eql? layout.data["rdf_prefix_path"])
            return layout.instance_variable_get(:@base_dir)
          end
          return search_prefix_definition layout.site.layouts[layout.data["layout"]], rdf_prefix_path unless layout.data["layout"].nil?
          return nil
        end

        def check_prefix_definition layout
          unless(layout.data["rdf_prefix_path"].nil?)
            return [layout.instance_variable_get(:@base_dir), layout.data["rdf_prefix_path"]]
          end
          return check_prefix_definition layout.site.layouts[layout.data["layout"]] unless layout.data["layout"].nil?
          return [nil, nil]
        end

        private
        class EqualObject
          def eql? object
            true
          end
        end

        @@equal_object = EqualObject.new
      end
    end
  end
end
