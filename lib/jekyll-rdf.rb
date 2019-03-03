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
##
# JekyllRdf converts RDF data into static websites
#
#
require 'jekyll'
require 'linkeddata'
require 'sparql'
require 'set'
require 'addressable/uri'
require 'pp'

require 'jekyll/helper/rdf_types'
require 'jekyll/types/XsdInteger'
require 'jekyll/types/XsdDecimal'
require 'jekyll/types/XsdDouble'
require 'jekyll/types/XsdBoolean'
require 'jekyll/drops/rdf_term'
require 'jekyll/drops/rdf_statement'
require 'jekyll/drops/rdf_literal'
require 'jekyll/drops/rdf_resource'
require 'jekyll/drops/rdf_resource_class'
require 'jekyll/exceptions/NoPrefixMapped'
require 'jekyll/exceptions/NoPrefixesDefined'
require 'jekyll/exceptions/UnMarkedUri'
require 'jekyll/helper/rdf_prefix_helper'
require 'jekyll/helper/rdf_general_helper'
require 'jekyll/helper/rdf_class_extraction'
require 'jekyll/helper/rdf_page_helper'
require 'jekyll/helper/rdf_generator_helper'
require 'jekyll/helper/rdf_filter_helper'
require 'jekyll/helper/rdf_hook_helper'
require 'jekyll/hooks/rdf_page_pointer'
require 'jekyll/filters/rdf_sparql_query'
require 'jekyll/filters/rdf_property'
require 'jekyll/filters/rdf_collection'
require 'jekyll/filters/rdf_container'
require 'jekyll/filters/rdf_get'
require 'jekyll/filters/rdf_debug_message'


Liquid::Template.register_filter(Jekyll::JekyllRdf::Filter)
require 'jekyll/rdf_main_generator'
require 'jekyll/rdf_template_mapper'
