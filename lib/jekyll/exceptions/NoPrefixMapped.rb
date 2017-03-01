class NoPrefixMapped < StandardError
  attr_accessor :prefix, :property
  def initialize property, layout, prefix
    @prefix, @property = prefix, property
    super("Their is no mapping defined for #{prefix} in context to #{property}\n in layout: '#{layout}'.")
  end
end
