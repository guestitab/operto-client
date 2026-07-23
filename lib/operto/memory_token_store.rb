module Operto
  # The default token store: keeps the token in memory for the life of the
  # process. Fine for a single long-running process (the token simply re-issues
  # after a restart); provide a shared/persistent store for multi-process
  # deployments.
  class MemoryTokenStore
    Token = Struct.new(:access_token, :refresh_token, :refresh_expires_at, :expires_at, keyword_init: true) do
      def expired?
        expires_at.nil? || expires_at < Time.now
      end
    end

    REFRESH_BUFFER = 120

    def active
      @token if @token && !@token.expired?
    end

    def refreshable
      @token if @token&.refresh_expires_at && @token.refresh_expires_at > Time.now + REFRESH_BUFFER
    end

    def save(access_token:, expires_at:, refresh_token: nil, refresh_expires_at: nil)
      @token = Token.new(access_token:, expires_at:, refresh_token:, refresh_expires_at:)
    end

    def clear
      @token = nil
    end
  end
end
