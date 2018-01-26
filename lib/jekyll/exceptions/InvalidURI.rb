class InvalidURI < StandardError
  def initialize uri_string
    super("The string `#{uri_string}` is not a valid uri.")
  end
end

