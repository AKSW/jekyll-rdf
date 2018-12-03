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

        def create_resource_class(class_search_results)
          class_search_results.each do |uri|
            @classResources[uri.to_s]=Jekyll::JekyllRdf::Drops::
              RdfResourceClass.new(uri)
          end

          @classResources.each{|key, value|
            value.find_direct_subclasses.each{|s|
              value.add_subclass(@classResources[s])
            }
          }
        end

        def assign_class_templates(classes_to_templates)
          if(classes_to_templates.is_a?(Hash))
            @classResources.default = StopObject.new
            classes_to_templates.each{|key, value|
              @classResources[key].propagate_template(value,0)
              @classResources[key].traverse_hierarchy_value(0)
            }
            @classResources.default = nil
          end
        end

        ##
        # TODO -hashing
        #      -reset lock for each call
        #      -make sure each class is added only once to class_list
        def request_class_template class_list
          #hash template and determine if we used these classes before
          #start searching
          lock = -1
          count = 0
          next_increase = -1
          min_template_lock = @stop_object    #ruby does not have MAX_VALUE
          min_template = nil
          class_list.map!{|uri|
            @classResources[uri] ||= Jekyll::JekyllRdf::Drops::RdfResourceClass(uri)
          }
          class_list.each{|class_resource|
            if(next_increase <= count)     # the next level of the breadth-first search
              lock += 1
              next_increase = class_list.length
            end
            class_resource.find_direct_superclasses.each{ |uri|
              @classResources[uri] ||= Jekyll::JekyllRdf::Drops::RdfResourceClass(uri)
              if(!@classResources[uri].template.nil?) # do not search in paths you previously found
                @classResources[uri].path = class_resource
                if @classResources[uri].base
                  @classResources[uri].propagate_template(0)
                  return @classResources[uri]
                elsif min_template_lock > (lock + @classResources[uri].dist) # you found a branche that was used earlier
                  min_template = @classResources[uri].template
                  min_template_lock = lock + @classResources[uri].dist
                end
              elsif(@classResources[uri].lock > class_resource.lock)
                class_list.push(@classResources[uri])
                @classResources[uri].path = class_resource
              end
            }
            count += 1
            return min_template if (min_template_lock <= lock)
          }
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
          def propagate_template(template, lock)
            return
          end

          def traverse_hierarchy_value(predecessorHierarchyValue)
            return
          end

          def >
            true
          end

          def <=
            false
          end

          def <
            false
          end
        end
      end
    end
  end
end
