module Jekyll
  module JekyllRdf
    module Helper
      module RdfClassExtraction

        private
        def create_class_map
          create_resource_class(search_for_classes)
        end

        def search_for_classes
          class_recognition_query = "SELECT DISTINCT ?resourceUri WHERE{ " <<
            "{?resourceUri <http://www.w3.org/2000/01/rdf-schema#subClassOf> ?o}" <<
            " UNION{ ?s <http://www.w3.org/2000/01/rdf-schema#subClassOf> ?resourceUri}" <<
            " UNION{ ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?resourceUri}}"
          class_search_results = Jekyll::JekyllRdf::Helper::RdfHelper::sparql.
            query(class_recognition_query).
            map{ |sol| sol[:resourceUri] }.reject do |s|  # Reject literals
              s.class <= RDF::Literal
            end
          return class_search_results
        end

        def create_resource_class(classes_to_templates)
          if(classes_to_templates.is_a?(Hash))
            classes_to_templates.each{|uri, template|
              @classResources[uri] = Jekyll::JekyllRdf::Drops::
              RdfResourceClass.new(RDF::URI(uri), true)
              @classResources[uri].template = template
            }
          end
        end

        def assign_class_templates(classes_to_templates)
          if(classes_to_templates.is_a?(Hash))
            classes_to_templates.each{|key, value|
              @classResources[key].propagate_template(value, 0)
              @classResources[key].traverse_hierarchy_value(0)
            }
          end
        end

        ##
        # TODO -hashing
        #      +reset lock for each call
        #      +make sure each class is added only once to class_list
        def request_class_template direct_classes, test
          #hash template and determine if we used these classes before
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
          class_list.each{|class_resource|
            if(next_increase <= count)     # the next level of the breadth-first search
              if ((min_template_lock <= lock) && (lock >= 1))  # if (distance to next template is smaller than current search radius) && (we checked all immediate classes)
                min_class.propagate_template(min_class.distance)
                return extract_template(min_class)
              end
              lock += 1
              next_increase = class_list.length
            end

            Jekyll.logger.info "checking #{class_resource}" if test
            if !class_resource.template.nil? && min_template_lock > lock - 1 + class_resource.distance
              min_template_lock = lock - 1
              min_class = class_resource
            end

            class_resource.find_direct_superclasses.each{ |uri|
              @classResources[uri] ||= Jekyll::JekyllRdf::Drops::RdfResourceClass.new(RDF::URI(uri))
              @classResources[uri].path = class_resource
              if(!@classResources[uri].template.nil?) # do not search in paths you previously found
                if @classResources[uri].base
                  min_template_lock = lock
                  min_class = @classResources[uri]
                elsif min_template_lock > (lock + @classResources[uri].distance) # you found a branch that was used earlier
                  min_template_lock = lock + @classResources[uri].distance
                  min_class = @classResources[uri]
                end
              elsif(!@classResources[uri].added?(lock_number) && @classResources[uri].lock > class_resource.lock) # not a previously searched resource without a template
                class_list.push(@classResources[uri])
                Jekyll.logger.info "found #{@classResources[uri]}" if test
                @classResources[uri].lock = lock
              end
            }
            count += 1
          }

          unless min_class.nil?
            return extract_template(min_class)
          end
          return nil
        end

        def extract_template class_resource
          class_resource.propagate_template(class_resource.distance)
          return class_resource.get_path_root.template
        end

        def clean_alternative_tmpl
          @classResources.each{|key, value|
            consistence_templates(value) if value.multiple_templates?
          }
        end

        ##
        # Add a warning for a class having multiple possible templates
        # The warnings are then later displayed with print_warnings
        #
        def consistence_templates(classRes)
          hash_str = classRes.alternativeTemplates.push(classRes.template).
            sort!.join(", ")
          begin
            @consistence[hash_str] = []
            @consistence[hash_str].push(classRes.template)
            @consistence[hash_str].push([])
          end if @consistence[hash_str].nil?
          classRes.template = @consistence[hash_str][0]
          @consistence[hash_str][1].push(classRes)  # using a hash ensures that a warning is printed only once for each combination of templates
                                                    # and for each resource at most once
        end

        class StopObject #unfortunately next does not work in this setup, it avoids to have "if" in every iteration
          def > object
            true
          end

          def <= object
            false
          end

          def < object
            false
          end
        end
      end
    end
  end
end
