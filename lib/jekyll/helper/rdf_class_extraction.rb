module Jekyll
  module JekyllRdf
    module Helper
      module RdfClassExtraction

        private

        ##
        # Instantiate all rdf:class'es with an template mapped in +classes_to_templates+.
        # +classes_to_templates+ A hash that contains string representations of class resources
        #  as keys and maps these to a template.
        #
        def create_resource_class(classes_to_templates)
          if(classes_to_templates.is_a?(Hash))
            classes_to_templates.each{|uri, template|
              @classResources[uri] = Jekyll::JekyllRdf::Drops::
              RdfResourceClass.new(RDF::URI(uri), true)
              @classResources[uri].template = template
            }
          end
        end

        ##
        # Returns to a RdfResource a template through its rdf:type
        # +resource+ the resource a template is searched for.
        #
        def request_class_template resource
          return nil if resource.direct_classes.empty?
          direct_classes = resource.direct_classes
          #hash template and determine if we used these classes before
          hash_str = direct_classes.sort!.join(", ")
          return @template_cache[hash_str] unless @template_cache[hash_str].nil?
          #start searching
          lock = -1
          count = 0
          next_increase = -1
          lock_number = rand
          min_template_lock = @stop_object    #ruby does not have MAX_VALUE
          min_class = nil
          class_list = direct_classes.map{|uri|
            @classResources[uri] ||= Jekyll::JekyllRdf::Drops::RdfResourceClass.new(RDF::URI(uri))
            @classResources[uri].path = nil
            @classResources[uri]
          }
          alternatives = []

          class_list.each{|class_resource|
            if(next_increase <= count)     # the next level of the breadth-first search
              if ((min_template_lock <= lock) && (lock >= 1))  # if (distance to next template is smaller than current search radius) && (we checked all immediate classes)
                return extract_template(find_highlevel_inheritance(min_class, alternatives, resource), hash_str)
              end
              alternatives.clear()
              lock += 1
              next_increase = class_list.length
            end

            if !class_resource.template.nil? && min_template_lock > lock - 1 + class_resource.distance
              min_template_lock = lock - 1
              min_class = class_resource
            end

            class_resource.find_direct_superclasses.each{ |uri|
              @classResources[uri] ||= Jekyll::JekyllRdf::Drops::RdfResourceClass.new(RDF::URI(uri))
              if(!@classResources[uri].template.nil?) # do not search in paths you previously found
                if @classResources[uri].base
                  if(!min_class.nil? && min_template_lock == lock)    #min_class could contain a previously found class with equal distance
                    alternatives.push @classResources[uri]
                  else
                    min_template_lock = lock
                    min_class = @classResources[uri]
                  end
                  @classResources[uri].path = class_resource  # <- this might be valnuable to cyclic inheritance in the graph
                elsif min_template_lock > (lock + @classResources[uri].distance) # you found a branch that was used earlier
                                                                                 # note template but search further unitl (min_template_lock <= lock) && (lock >= 1) is satisfied
                  @classResources[uri].path = class_resource  # <- this might be valnuable to cyclic inheritance in the graph
                  min_template_lock = lock + @classResources[uri].distance
                  min_class = @classResources[uri]
                elsif min_template_lock == (lock + @classResources[uri].distance)
                  alternatives.push @classResources[uri]
                end
              elsif(@classResources[uri].add?(lock_number) && @classResources[uri].lock > class_resource.lock) # not a previously searched resource without a template
                @classResources[uri].path = class_resource  # <- this might be valnuable to cyclic inheritance in the graph
                class_list.push(@classResources[uri])
                @classResources[uri].lock = lock
              end
            }
            count += 1
          }

          unless min_class.nil?
            return extract_template(find_highlevel_inheritance(min_class, alternatives, resource), hash_str)
          end
          return nil
        end

        ##
        # Returns the template stored in the input resource +class_resource+
        #  and caches it with +hash_str+ as key.
        #
        def extract_template class_resource, hash_str
          class_resource.propagate_template(class_resource.distance)
          return (@template_cache[hash_str] = class_resource.get_path_root.template)
        end

        ##
        # Returns the most specific class resource from +class_list+ based on
        # +current_best+.
        # +resource+ is the original input of request_class_template.
        #
        def find_highlevel_inheritance current_best, class_list, resource   #check at the end of the search for direct inheritance on highest level
          class_list.each{|resource|
            resource.find_direct_superclasses.each{|uri|
              @classResources[uri] ||= Jekyll::JekyllRdf::Drops::RdfResourceClass.new(RDF::URI(uri))
              @classResources[uri].path = resource
            } if resource.base
          }
          # this is valnuable to cyclic inheritance
          while(class_list.include?(current_best.path))
            slice = class_list.index(current_best)
            # parent alternatives are no real alternatives
            class_list.slice!(slice) unless slice.nil?
            current_best = current_best.path
          end
          return consistence_templates(current_best, class_list, resource) unless class_list.empty?
          return current_best
        end

        ##
        # Add a warning for a class having multiple possible templates
        # The warnings are then later displayed with print_warnings
        # +classRes+ and +alternatives+ make up a list of class resources which
        #     are all equally valid choices for request_class_template
        # +resource+ is the original input of request_class_template.
        #
        def consistence_templates(classRes, alternatives, resource)
          hash_str = alternatives.push(classRes).
            map {|x|
              x.template
            }.
            sort!.join(", ")
          begin
            @consistence[hash_str] = []
            @consistence[hash_str].push(classRes)
            @consistence[hash_str].push([])
          end if @consistence[hash_str].nil?
          @consistence[hash_str][1].push(resource)  # using a hash ensures that a warning is printed only once for each combination of templates
                                                    # and for each resource at most once
          @consistence[hash_str][0]
        end

        ##
        # used to escape loops without an if-statement
        #
        class StopObject
          def > object
            true
          end

          def <= object
            false
          end
        end
      end
    end
  end
end
