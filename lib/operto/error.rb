module Operto
  class Error < StandardError; end

  # Raised by operations for malformed arguments before any network call.
  class ArgumentError < Error; end

  # Raised when Operto answers a single-record read with nothing.
  class NotFoundError < Error; end
end
