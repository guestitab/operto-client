module Operto
  module AccessTokens
    # Ensures a live access token: reuse the stored one, else refresh, else log
    # in fresh. All persistence/caching/expiry policy lives in the injected
    # token store (Operto.config.token_store).
    class Upsert
      include Operto::Operation

      OAUTH_ENDPOINT   = 'oauth/login'.freeze
      REFRESH_ENDPOINT = 'oauth/refresh'.freeze

      # @rbs () -> Dry::Monads::Result[untyped]
      def call
        token = store.active
        return Success(token) if token

        attempt_refresh || request_new_token
      rescue StandardError => e
        Failure(e)
      end

      private

      def store
        Operto.config.token_store
      end

      def attempt_refresh
        token = store.refreshable
        return unless token

        response = Operto::Client.connection(skip_auth: true).get(REFRESH_ENDPOINT) do |req|
          req.headers['Authorization'] = "VRS #{token.refresh_token}"
        end

        return unless Operto::Client.successful_response?(response)

        Success(update_token(response.body, refresh_only: true))
      end

      def request_new_token
        response = Operto::Client.connection(skip_auth: true).post(OAUTH_ENDPOINT) do |req|
          req.body = { API_Key: Operto::Client.client_id, API_Value: Operto::Client.secret }
        end

        Operto::Client.handle_response(response) { |body| update_token(body) }
      end

      def update_token(body, refresh_only: false)
        access = body[:Access_Token]
        attributes = { access_token: access[:token], expires_at: access[:Expiry].to_i.seconds.from_now }

        unless refresh_only
          refresh = body[:Refresh_Token]
          attributes[:refresh_token] = refresh[:token]
          attributes[:refresh_expires_at] = refresh[:Expiry].to_i.seconds.from_now
        end

        store.save(**attributes)
      end
    end
  end
end
