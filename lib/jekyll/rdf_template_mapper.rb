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
  # Jekyll::RdfTemplateMapper maps resources to templates
  #
  class RdfTemplateMapper

    include Jekyll::JekyllRdf::Helper::RdfClassExtraction

    ##
    # Create a new Jekyll::RdfTemplateMapper
    #
    # * +resources_to_templates+ - A Hash mapping a type resource to a template name
    # * +default_template+ - Default template name
    def initialize(resources_to_templates, classes_to_templates, default_template)
      @resources_to_templates = resources_to_templates
      @default_template = default_template
      @classResources = {}
      @consistence = {}    #ensures that the same template is chosen for each combination of templates
      @template_cache = {}
      @stop_object = StopObject.new

      create_resource_class(classes_to_templates)
    end

    ##
    # Maps a resource to a template name.
    #
    # Returns the template name of one of the +resource+'s types, if available. Returns the default template name otherwise.
    def map(resource)
      tmpl = @resources_to_templates ? @resources_to_templates[resource.term.to_s] : nil
      tmpl = request_class_template(resource.direct_classes) if tmpl.nil? && !resource.direct_classes.empty?
      return tmpl unless tmpl.nil?
      return @default_template
    end

    def print_warnings
      @consistence.each{ |key, template_class_store|
        Jekyll.logger.warn("Warning: multiple possible templates for resources #{template_class_store[1].join(", ")}\nPossible Templates: #{key}")
        true
      }
    end
  end # RdfTemplateMapper
end #Jekyll
