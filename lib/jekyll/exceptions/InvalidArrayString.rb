class InvalidArrayString < StandardError
  def initialize array_string
    super("The string `#{array_string}` is not a valid array.")
  end
end
