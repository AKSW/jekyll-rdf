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
              @classResources[key].traverse_hierarchy_value(0);
            }
            @classResources.default = nil
          end
        end

        class StopObject #unfortunately next does not work in this setup, it avoids to have "if" in every iteration
          def propagate_template(template, lock)
            return
          end

          def traverse_hierarchy_value(predecessorHierarchyValue)
            return
          end
        end
      end
    end
  end
end
