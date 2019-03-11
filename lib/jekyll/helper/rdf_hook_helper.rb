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
          # posts frontmatter does not contain values from layout frontmatters
          if(prefix_path.nil?)
            unless(payload.layout.nil? || page.data["layout"].nil?)
              prefix_path = payload.layout["rdf_prefix_path"]
              base_path = search_prefix_definition page.site.layouts[page.data["layout"]], prefix_path
            end
          else
            base_path = payload.site["source"]#page.path[0..-(page.relative_path.length + 1)]
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
          return search_prefix_definition layout.site.layouts[layout.data["layout"]], rdf_prefix_path
        end
      end
    end
  end
end
