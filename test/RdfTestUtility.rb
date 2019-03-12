module RdfTestUtility
  def setup_jekyll path
    @source = path
    config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
    site = Jekyll::Site.new(config)
    Jekyll::JekyllRdf::Helper::RdfHelper.reinitialize
    site.process
  end

  def setup_site_jekyll path
    @source = path
    config = Jekyll.configuration(YAML.load_file(File.join(@source, '_config.yml')).merge!({'source' => @source, 'destination' => File.join(@source, "_site")}))
    @site = Jekyll::Site.new(config)
    Jekyll::JekyllRdf::Helper::RdfHelper.reinitialize
    @site.process
  end
end