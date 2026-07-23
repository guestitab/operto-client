module Operto
  class Error < StandardError; end

  # Raised by operations for malformed arguments before any network call.
  class ArgumentError < Error; end
end
