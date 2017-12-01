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
      ##
      # Internal module to hold support for functionalities like submitting sparql queries
      #
      module RdfPrefixHelper
        ##
        # loads the prefix data passed in the layout yaml-frontmatter or in _config.yml into page.data["rdf_prefixes"] and page.data["rdf_prefix_map"]
        def load_prefixes(path, prefHolder)
          Jekyll::JekyllRdf::Helper::RdfHelper.load_prefixes(path, prefHolder)
        rescue Errno::ENOENT => ex
          Jekyll.logger.error("--> context resource: #{@resource}  template: #{@template}") if self.class <= Jekyll::RdfPageData
        end
      end

    end
  end
end
