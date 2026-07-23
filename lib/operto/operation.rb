module Operto
  # Shared monadic contract for the client operations: #call returns a Result,
  # #call! unwraps it and raises the underlying failure.
  module Operation
    def self.included(base)
      base.include Dry::Monads[:result]
    end

    def call!(...)
      result = call(...)
      raise result.failure if result.failure?

      result
    end

    private

    def argument!(**attrs)
      key, reason = attrs.first
      raise Operto::ArgumentError, "#{key}: #{reason}"
    end

    def required_attribute!(key)
      raise Operto::ArgumentError, "#{key}: required"
    end

    def invalid_attribute!(key, type:)
      raise Operto::ArgumentError, "#{key}: expected #{type}"
    end
  end
end
