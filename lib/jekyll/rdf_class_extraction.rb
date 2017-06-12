module Jekyll
  module RdfClassExtraction
    private
      def search_for_classes(sparql)
        class_recognition_query = "SELECT DISTINCT ?resourceUri WHERE{ {?resourceUri <http://www.w3.org/2000/01/rdf-schema#subClassOf> ?o} UNION{ ?s <http://www.w3.org/2000/01/rdf-schema#subClassOf> ?resourceUri} UNION{ ?s <http://www.w3.org/1999/02/22-rdf-syntax-ns#type> ?resourceUri}}"
        class_search_results = sparql.query(class_recognition_query).map{ |sol| sol[:resourceUri] }.reject do |s|  # Reject literals
          s.class <= RDF::Literal
        end.select do |s|  # Select URIs and blank nodes in case of include_blank
          s.class <=RDF::Node || s.class <= RDF::URI
        end
        return class_search_results
      end

      def create_resource_class(class_search_results, sparql)
	      class_search_results.each do |uri|
	        @classResources[uri.to_s]=Jekyll::Drops::RdfResourceClass.new(uri, sparql)
	      end

        @classResources.each{|key, value|
          value.findDirectSubClasses.each{|s|
            value.addSubClass(@classResources[s])
          }
        }
      end

      def assign_class_templates(classes_to_templates)
        if(classes_to_templates.is_a?(Hash))
          classes_to_templates.each{|key, value|
            @classResources[key].propagateTemplate(value,0)
            @classResources[key].traverseHierarchyValue(0);
          }
        end
      end
  end
end
