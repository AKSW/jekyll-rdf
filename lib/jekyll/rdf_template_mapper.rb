module Jekyll

  ##
  # JekyllRdf::RdfTemplateMapper maps resources to templates
  #
  class RdfTemplateMapper
    
    ##
    # 
    attr_accessor :resources_to_templates
    
    ##
    #
    attr_accessor :default

    def initialize(resources_to_templates, default)
      @resources_to_templates = resources_to_templates
      @default = default
    end

    def map resource
      resource.types.each do |type|
        tmpl = resources_to_templates[type]
        return tmpl unless tmpl.nil?
      end
      return default
    end

  end

end
