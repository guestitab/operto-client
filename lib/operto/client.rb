module Operto
  # The single HTTP gateway: Faraday connection, auth header, retry, and Operto's
  # quirky response envelope (a 200 with ReasonCode >= 300 is a failure).
  module Client
    extend self
    include Dry::Monads[:result]

    RETRY_OPTIONS = {
      max: 3,
      interval: 1.0,
      interval_randomness: 0.5,
      backoff_factor: 2,
      retry_statuses: [401, 429, 502, 503, 504],
      exceptions: [*Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS, Faraday::ConnectionFailed],
      methods: [*Faraday::Retry::Middleware::IDEMPOTENT_METHODS, :patch, :post],
      retry_block: ->(env:, **) { Operto.config.token_store.clear if env.status == 401 }
    }.freeze

    def connection(url: Operto.config.base_url, skip_auth: false)
      Faraday.new(url:) do |builder|
        builder.request :authorization, 'VRS', -> { auth_token } unless skip_auth

        builder.request :json
        builder.request :retry, RETRY_OPTIONS
        builder.request :url_encoded
        builder.response :json, parser_options: { symbolize_names: true, mode: :rails, decoder: [Oj, :load] }
        builder.options[:timeout] = 20
      end
    end

    def handle_response(response, &block)
      return Failure(formatted_error(response)) unless successful_response?(response)

      Success(block ? block.call(response_body(response)) : true)
    end

    def successful_response?(response)
      body = response_body(response)
      reason_code = body[:ReasonCode]

      response.success? && (reason_code.nil? || reason_code.to_i < 300)
    end

    def formatted_error(response)
      body = response_body(response)
      reason_code = body[:ReasonCode] || response.status
      reason_text = body[:ReasonText] || body[:Message] || response.body.to_s

      Operto::Error.new("#{reason_code}: #{reason_text}")
    end

    def response_body(response)
      body = response.body
      return body if body.is_a?(Hash)

      parsed_body_from_string(body)
    end

    def parsed_body_from_string(body)
      string_body = body.to_s
      return {} if string_body.empty?

      parsed = Oj.load(string_body, symbol_keys: true)
      parsed.is_a?(Hash) ? parsed : {}
    rescue StandardError
      {}
    end

    def auth_token
      AccessTokens::Upsert.new.call!.value!.access_token
    end

    def client_id
      Operto.config.client_id
    end

    def secret
      Operto.config.secret
    end
  end
end
