module Jekyll

  ##
  # JekyllRdf::RdfTemplateMapper maps resources to templates
  #
  class RdfTemplateMapper
    
    ##
    # 
    attr_accessor :config
    
    ##
    #
    attr_accessor :default

    def initialize(config, default)
      @config = config
      @default = default
    end

    def map resource
      resource.types.each do |type|
        tmpl = config[type]
        return tmpl unless tmpl.nil?
      end
      return default
    end

  end

end
