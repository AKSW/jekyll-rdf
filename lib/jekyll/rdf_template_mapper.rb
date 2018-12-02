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
      @classes_to_templates = classes_to_templates
      @classResources = {}
      @warnings = {}
      create_class_map
      assign_class_templates(classes_to_templates)
    end

    ##
    # Maps a resource to a template name.
    #
    # Returns the template name of one of the +resource+'s types, if available. Returns the default template name otherwise.
    def map(resource)
      tmpl = @resources_to_templates ? @resources_to_templates[resource.term.to_s] : nil
      lock = -1
      hier = -1
      duplicate_level_templ = []
      resource.direct_classes.each do |classUri|
        classRes = @classResources[classUri]
        if((classRes.lock <= lock || lock == -1) && !classRes.template.nil?)
          if(classRes.subClassHierarchyValue > hier)
            lock = classRes.lock
            tmpl = classRes.template
            hier = classRes.subClassHierarchyValue
            duplicate_level_templ.clear.push(tmpl)
            if(classRes.multiple_templates?)
              duplicate_level_templ.concat(classRes.alternativeTemplates)
            end
          elsif(classRes.subClassHierarchyValue == hier)
            duplicate_level_templ.push(classRes.template)
          end
        end unless classRes.nil?
      end if(tmpl.nil?)
      add_warning(duplicate_level_templ.uniq, resource.iri) if (duplicate_level_templ.length > 1) && (Jekyll.env.eql? "development")
      return tmpl unless tmpl.nil?
      return @default_template
    end

    ##
    # Add a warning for a resource having multiple possible templates
    # The warnings are then later displayed with print_warnings
    #
    def add_warning(keys, iri)
      keys.sort!
      key = keys.join(', ')
      @warnings[key] = [] if @warnings[key].nil?  # using a hash ensures that a warning is printed only once for each combination of templates
                                                  # and for each resource at most once
      @warnings[key].push(iri) unless @warnings[key].include? iri
    end

    def print_warnings
      @warnings.delete_if{ |key, iris|
        Jekyll.logger.warn("Warning: multiple possible templates for resources #{iris.join(", ")}\nPossible Templates: #{key}")
        true
      }
    end
  end # RdfTemplateMapper
end #Jekyll
