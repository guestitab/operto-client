module Operto
  # Faraday middleware that signs each request with the stored access token.
  # When Operto rejects the token (a 401 or an auth_token_expired envelope), it
  # clears the store, renews the token and replays the request once.
  class Authorization < Faraday::Middleware
    HEADER = 'Authorization'.freeze
    EXPIRED_REASON = 'auth_token_expired'.freeze

    def call(env)
      request_body = env.body
      response = @app.call(sign(env))
      return response unless rejected?(response)

      Operto.config.token_store.clear
      env.body = request_body
      @app.call(sign(env))
    end

    private

    def sign(env)
      env.request_headers[HEADER] = "VRS #{Operto::Client.auth_token}"
      env
    end

    def rejected?(response)
      response.status == 401 || Operto::Client.response_body(response)[:ReasonText].to_s.include?(EXPIRED_REASON)
    end
  end
end
