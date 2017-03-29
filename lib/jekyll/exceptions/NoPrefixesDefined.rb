class NoPrefixesDefined < StandardError
  def initialize x, layout
    super("No Prefixes are defined when #{x} gets passed in \n layout: '#{layout}'.")
  end
end
