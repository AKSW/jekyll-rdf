require 'pp'

class ResourceHelper
  def initialize(sparql)
    @sparql = sparql
  end

  def basic_resource(uri)
    resource = Jekyll::Drops::RdfResource.new(RDF::URI.new(uri), @sparql)
    attach_site(resource, create_fake_site())
    attach_page(resource, create_fake_page())
    return resource
  end

  def basic_literal(string)
    literal = Jekyll::Drops::RdfLiteral.new(RDF::Literal.new(string), @sparql)
    return literal
  end

  def resource_with_prefixes_config(uri, prefixHash)
    resource = basic_resource(uri)
    attach_prefixes(resource, prefixHash)
    attach_config(resource, create_config_language('en'))
    return resource
  end

  def resource_faulty_sparql(uri, exception)  #Fehleranfällig
    faulty_sparql = Object.new
    case exception
    when :ClientError
      def faulty_sparql.query(x)
        raise SPARQL::Client::ClientError
      end
    when :MalformedQuery
      def faulty_sparql.query(x)
        raise SPARQL::MalformedQuery
      end
    when :Exception
      def faulty_sparql.query(x)
        raise Exception
      end
    end
    resource = Jekyll::Drops::RdfResource.new(RDF::URI.new(uri), faulty_sparql)
    attach_site(resource, create_fake_site())
    attach_page(resource, create_fake_page())
    return resource
  end

  def attach_site(resource, site)
    if(!resource.respond_to?(:site))
      def resource.site= (obj)
        @site = obj
      end
      def resource.site
        @site
      end
    end
    resource.site = site
  end

  def attach_page(resource, page)
    if(!resource.respond_to?(:page))
      def resource.page= (obj)
        @page = obj
      end
      def resource.page
        @page
      end
    end
    resource.page = page
  end

  def attach_prefixes(resource, prefixHash)
    resource.page.data["rdf_prefix_map"] = prefixHash.clone()
    resource.page.data["rdf_prefixes"] = ""
    prefixHash.each {|prefix, uri|
      resource.page.data["rdf_prefixes"] += "PREFIX #{prefix}: <#{uri}>  "
    }
  end

  def attach_config(resource, config)
    resource.site.config.merge! config
  end

  def create_fake_page()
    fake_page = Object.new
    def fake_page.data
      if(@data.nil?)
        @data = {}
      end
      return @data
    end
    return fake_page
  end

  def create_fake_site()
    fake_site = Object.new
    def fake_site.config
      if(@config.nil?)
        @config = {}
      end
      return @config
    end
    return fake_site
  end

  def create_config_language (lang)
    config = {
      'jekyll_rdf' => {
        'language' => 'en'
      }
    }
    return config
  end

end
