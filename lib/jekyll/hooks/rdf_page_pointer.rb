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


Jekyll::Hooks.register :pages, :pre_render do |page, payload|
  if(page.class <= Jekyll::RdfPageData)
    payload["content"] = page.payload_content
  end
#  if page.data["title"].eql? "RenderConflict"
#    pp page
#  end
  Jekyll::JekyllRdf::Helper::RdfHelper::page = page
end

Jekyll::Hooks.register :pages, :post_render do |page, payload|
  rdf_page = Jekyll::JekyllRdf::Helper::RdfHelper::page_path?(page)
  unless (rdf_page.nil?) || (page.eql? rdf_page)
    rdf_page.change_output(page.output)
  end
end
