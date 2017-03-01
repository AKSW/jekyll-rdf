class UnMarkedUri < StandardError
  def initialize uri, layout
    super("The URI #{uri} is not correctly marked. Pls use the form <#{uri}> instead.\nFound in layout: '#{layout}'.")
  end
end
