module Jekyll

  ##
  # JekyllRdf::RdfTemplateMapper maps resources to templates
  #
  class RdfTemplateMapper
    
    ##
    # A hash mapping a type resource to a template name
    attr_accessor :resources_to_templates
    
    ##
    # Default template name
    attr_accessor :default_template

    ##
    # Create a new JekyllRdf::RdfTemplateMapper
    #
    # * +resources_to_templates+ - A hash mapping a type resource to a template name  
    # * +default_template+ - Default template name
    def initialize(resources_to_templates, default_template)
      @resources_to_templates = resources_to_templates
      @default_template = default_template
    end

    ##
    # Maps a resource to a template name. 
    #
    # Returns the template name of one of the +resource+'s types, if available. Returns the default template name otherwise.
    def map(resource)
      resource.types.each do |type|
        tmpl = resources_to_templates[type]
        return tmpl unless tmpl.nil?
      end
      return default_template
    end

  end

end
